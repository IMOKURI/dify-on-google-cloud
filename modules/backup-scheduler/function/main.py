"""
Filestore Backup Cloud Function

This function creates backups of a Filestore instance and manages retention.
"""

import os
import logging
from datetime import datetime, timedelta
from typing import Dict, Any

import functions_framework
from google.cloud import file_v1
from google.api_core import exceptions

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Environment variables
PROJECT_ID = os.environ.get('PROJECT_ID')
FILESTORE_INSTANCE = os.environ.get('FILESTORE_INSTANCE')
FILESTORE_LOCATION = os.environ.get('FILESTORE_LOCATION')
FILESTORE_SHARE_NAME = os.environ.get('FILESTORE_SHARE_NAME')
BACKUP_LOCATION = os.environ.get('BACKUP_LOCATION', FILESTORE_LOCATION)
RETENTION_DAYS = int(os.environ.get('RETENTION_DAYS', '7'))


@functions_framework.http
def create_backup(request) -> tuple[str, int]:
    """
    HTTP Cloud Function to create Filestore backup and clean up old backups.

    Args:
        request: HTTP request object

    Returns:
        Tuple of (response message, HTTP status code)
    """
    try:
        logger.info("Starting Filestore backup process")
        logger.info(f"Instance: {FILESTORE_INSTANCE}")
        logger.info(f"Location: {FILESTORE_LOCATION}")
        logger.info(f"Share: {FILESTORE_SHARE_NAME}")
        logger.info(f"Backup location: {BACKUP_LOCATION}")
        logger.info(f"Retention days: {RETENTION_DAYS}")

        # Initialize Filestore client
        client = file_v1.CloudFilestoreManagerClient()

        # Create backup
        backup_name = create_filestore_backup(client)
        logger.info(f"Backup created successfully: {backup_name}")

        # Clean up old backups if retention is set
        if RETENTION_DAYS > 0:
            deleted_count = cleanup_old_backups(client)
            logger.info(f"Cleaned up {deleted_count} old backups")
            message = f"Backup created: {backup_name}. Deleted {deleted_count} old backups."
        else:
            message = f"Backup created: {backup_name}"

        return message, 200

    except Exception as e:
        error_message = f"Backup failed: {str(e)}"
        logger.error(error_message, exc_info=True)
        return error_message, 500


def create_filestore_backup(client: file_v1.CloudFilestoreManagerClient) -> str:
    """
    Create a new Filestore backup.

    Args:
        client: Filestore client instance

    Returns:
        Name of the created backup
    """
    # Generate backup name with timestamp
    timestamp = datetime.utcnow().strftime('%Y%m%d-%H%M%S')
    backup_name = f"backup-{timestamp}"

    # Prepare backup request
    parent = f"projects/{PROJECT_ID}/locations/{BACKUP_LOCATION}"
    backup = file_v1.Backup(
        source_instance=FILESTORE_INSTANCE,
        source_file_share=FILESTORE_SHARE_NAME,
        description=f"Automated backup created at {timestamp}",
    )

    request = file_v1.CreateBackupRequest(
        parent=parent,
        backup=backup,
        backup_id=backup_name,
    )

    # Create backup (async operation)
    operation = client.create_backup(request=request)
    logger.info(f"Backup creation started: {backup_name}")

    # Note: We're not waiting for completion to avoid function timeout
    # The backup will continue in the background
    return f"{parent}/backups/{backup_name}"


def cleanup_old_backups(client: file_v1.CloudFilestoreManagerClient) -> int:
    """
    Delete backups older than the retention period.

    Args:
        client: Filestore client instance

    Returns:
        Number of backups deleted
    """
    if RETENTION_DAYS <= 0:
        return 0

    parent = f"projects/{PROJECT_ID}/locations/{BACKUP_LOCATION}"
    cutoff_date = datetime.utcnow() - timedelta(days=RETENTION_DAYS)
    deleted_count = 0

    try:
        # List all backups
        request = file_v1.ListBackupsRequest(parent=parent)
        backups = client.list_backups(request=request)

        for backup in backups:
            # Check if backup is for our instance
            if backup.source_instance != FILESTORE_INSTANCE:
                continue

            # Check if backup is older than retention period
            backup_time = backup.create_time
            if backup_time and backup_time.timestamp() < cutoff_date.timestamp():
                try:
                    logger.info(f"Deleting old backup: {backup.name}")
                    delete_request = file_v1.DeleteBackupRequest(name=backup.name)
                    client.delete_backup(request=delete_request)
                    deleted_count += 1
                except exceptions.NotFound:
                    logger.warning(f"Backup not found (may be already deleted): {backup.name}")
                except Exception as e:
                    logger.error(f"Failed to delete backup {backup.name}: {str(e)}")

    except Exception as e:
        logger.error(f"Error during backup cleanup: {str(e)}")

    return deleted_count
