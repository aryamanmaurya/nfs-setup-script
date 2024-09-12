
# NFS Server Setup Automation Script

This Bash script automates the process of setting up an NFS server on CentOS or RHEL-based operating systems. It includes package installation, configuration of shared directories, firewall settings, and instructions for mounting the shared directories on other client systems.

## Features
- **Automated Installation**: Installs required NFS packages and configures the firewall automatically.
- **Network Configuration**: Auto-detects the network interface and calculates the network ID to ensure the NFS share is only accessible from the correct network.
- **Flexible Directory Setup**: Allows the user to specify the directory to be shared, with read-only as the default option, and read-write as an optional setting.
- **Error Handling**: The script validates user inputs for directory paths and network interfaces, allowing multiple attempts before exiting.
- **Mount Instructions**: Provides clear instructions for client machines on how to mount the shared directory.

## Requirements
- CentOS or RHEL-based operating system
- Root or sudo privileges
- Internet connection to download necessary packages

## Usage
1. Clone the repository:
    ```bash
    git clone <repository_url>
    cd <repository_name>
    ```

2. Make the script executable:
    ```bash
    chmod +x nfs_setup.sh
    ```

3. Run the script:
    ```bash
    sudo ./nfs_setup.sh
    ```

4. Follow the prompts to:
   - Enter the directory path to share.
   - Set the permissions (read-only by default, read-write optional).
   - Select the network interface to use for sharing.
   
   The script will:
   - Install required NFS and firewall packages.
   - Configure the firewall to allow NFS traffic.
   - Set up the directory sharing with the selected network and permissions.
   - Restart the NFS server to apply the changes.

5. Once complete, follow the provided instructions to mount the NFS share on client machines.

## Example Usage
- Enter a valid directory path (e.g., `/home/user/shared`).
- Set the permissions (`y` for read-write or `n` for read-only).
- Select the network interface (e.g., `enp0s8`).

After completion, the script will display the necessary commands to mount the NFS share from client machines.

## Mounting Instructions (Client Machines)
1. Install NFS utilities on the client:
    ```bash
    sudo yum install -y nfs-utils
    ```

2. Create a directory on the client to mount the shared folder:
    ```bash
    sudo mkdir -p /mnt/nfs_share
    ```

3. Mount the shared directory:
    ```bash
    sudo mount <SERVER_IP>:/path/to/shared/directory /mnt/nfs_share
    ```

4. To make the mount permanent, add this to `/etc/fstab`:
    ```bash
    <SERVER_IP>:/path/to/shared/directory /mnt/nfs_share nfs defaults 0 0
    ```

## Notes
- Make sure the client machine is in the same network as the NFS server.
- Verify that the shared directory has the correct permissions for the client machines to access.
- Modify firewall settings if necessary to allow NFS traffic.

## Troubleshooting
- If the NFS share is not accessible from the client, check the firewall and network settings on both the server and the client.
- Ensure that the correct network interface is selected during the script execution.

## License
This project is licensed under the MIT License.
