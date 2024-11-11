# ctftool

A simple shell script for managing CTF challenges. This script allows you to create, delete, set, and list CTFs and challenges within them.

## Installation

1. Clone the repository to your local machine.

    ```bash
    git clone https://github.com/Eirikalv1/ctftool.git
    cd ctftool
    ```

2. Make the script executable.

    ```bash
    chmod +x ctftool.sh
    ```

3. Add it to bashrc. ctftool.sh should be in the same directory as your CTF challenge directories.

    ```bash
    echo -e "alias ctf=\"source <DIRECTORY>/ctftool.sh\"\nctf rc" >> ~/.bashrc
    ```

## Usage

```
  ctf new <ctfname>                 - Create a new CTF with the specified name.
  ctf delete <ctfname>              - Delete an existing CTF.
  ctf set <ctfname>                 - Set the current CTF directory.
  ctf unset                         - Unset the current CTF and challenge.
  ctf list                          - List all CTFs available.
  ctf chal new <challenge name>     - Create a new challenge in the current CTF.
  ctf chal delete <challenge name>  - Delete a challenge in the current CTF.
  ctf chal set <challenge name>     - Set the current challenge in the CTF.
  ctf chal unset                    - Unset the current challenge in the current CTF.
  ctf chal list                     - List all challenges in the current CTF.
```