- git_clone_simplified.py 
For the cd command to actually change the directory of your current shell session, you must source the script. Running python3 script.py executes the script in its own process, and any os.chdir() calls only affect that process, not your interactive shell.

How to run (Linux/Fedora):
source ./git_clone_simplified.py https://github.com/your-username/your-repo.git
source ./git_clone_simplified.py https://github.com/your-username/your-repo.git my_new_project_folder
