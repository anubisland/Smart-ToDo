## Smart-ToDo 1.0.7

### Optional encrypted backups
- Create an encrypted backup protected by a password of at least 12 characters.
- Restore encrypted `.stbackup` files with that password.
- Existing unencrypted JSON backup and restore remains supported.
- Uses Argon2id to derive an encryption key and authenticated AES-256-GCM to protect backup contents.
- The password is not stored or recoverable. Keep it somewhere safe; losing it means the encrypted backup cannot be restored.

### Upgrade
This APK keeps the existing signing certificate and can be installed over Smart-ToDo 1.0.6.
