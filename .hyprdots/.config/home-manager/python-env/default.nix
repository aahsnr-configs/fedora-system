{ config, pkgs, lib, ... }:

let
  # Create an optimized Python build using overlay approach (more reliable than overrideAttrs)
  optimizedPython = pkgs.python313.override {
    # Enable optimizations at the interpreter level
    enableOptimizations = true;
    
    # Use reproducible but still optimized builds
    reproducibleBuild = false;
    
    # Enable additional features
    enableLTO = true;
    
    # Override the build process more carefully
    self = pkgs.python313;
    
    # Custom configure flags that are known to work
    stdenv = pkgs.stdenv.override {
      cc = pkgs.gcc.override {
        # Use optimization flags that don't break reproducibility
        extraBuildCommands = ''
          export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -O3 -pipe -flto"
        '';
      };
    };
  };

  # Create Python environment with scientific packages
  pythonEnv = optimizedPython.withPackages (ps: with ps; [
    # Essential Jupyter components
    jupyter
    jupyterlab
    ipython
    ipykernel
    notebook
    
    # Core scientific computing stack
    numpy
    scipy
    pandas
    matplotlib
    seaborn
    plotly
    
    # Machine learning
    scikit-learn
    
    # Data visualization
    bokeh
    altair
    
    # Web frameworks
    flask
    fastapi
    requests
    urllib3
    
    # Database connectivity
    sqlalchemy
    psycopg2
    
    # Development tools
    pytest
    black
    isort
    flake8
    mypy
    
    # Utilities
    click
    pydantic
    rich
    typer
    tqdm
    
    # File handling
    openpyxl
    xlsxwriter
    pillow
    
    # Configuration and serialization
    pyyaml
    toml
    
    # Date/time handling
    python-dateutil
    
    # Async programming
    aiohttp
    asyncio
    
    # Package management
    pip
    setuptools
    wheel
    
    # Additional scientific packages
    sympy
    networkx
    statsmodels
    
    # Jupyter extensions
    jupyterlab-git
    jupyterlab-lsp
    
    # Code quality
    autopep8
    pycodestyle
  ]);

  # Custom Jupyter configuration
  jupyterConfig = {
    notebook = ''
      import sys
      import os
      
      c = get_config()
      
      # Server configuration
      c.ServerApp.ip = '127.0.0.1'
      c.ServerApp.port = 8888
      c.ServerApp.open_browser = False
      c.ServerApp.root_dir = os.path.expanduser('~/Documents/notebooks')
      
      # Security settings
      c.ServerApp.token = ''
      c.ServerApp.password = ''
      c.ServerApp.disable_check_xsrf = False
      c.ServerApp.allow_remote_access = False
      
      # Performance settings
      c.ServerApp.max_buffer_size = 268435456  # 256MB
      c.ServerApp.iopub_data_rate_limit = 10000000  # 10MB/s
      c.ServerApp.rate_limit_window = 3.0
      
      # Kernel management
      c.MultiKernelManager.default_kernel_name = 'nix-python'
    '';
    
    lab = ''
      import sys
      import os
      
      c = get_config()
      
      # Server configuration
      c.ServerApp.ip = '127.0.0.1'
      c.ServerApp.port = 8888
      c.ServerApp.open_browser = False
      c.ServerApp.root_dir = os.path.expanduser('~/Documents/notebooks')
      
      # Security settings
      c.ServerApp.token = ''
      c.ServerApp.password = ''
      c.ServerApp.allow_remote_access = False
      
      # Lab-specific settings
      c.LabApp.dev_mode = False
      c.LabApp.watch = False
      
      # Performance settings
      c.ServerApp.max_buffer_size = 268435456  # 256MB
      c.ServerApp.iopub_data_rate_limit = 10000000  # 10MB/s
    '';
  };

in
{
  home = {
    packages = with pkgs; [
      # Core Python environment
      pythonEnv
      
     
      # Build tools (for pip packages that need compilation)
      gcc
      gnumake
      pkg-config
      
      # System libraries commonly needed by Python packages
      zlib
      openssl
      libffi
      
      # Database clients
      sqlite
      postgresql
      
      # Document generation
      pandoc
      graphviz
      
      # Optional: Version control for notebooks
      nbstripout
    ];
    
    # Environment variables for Python isolation
    sessionVariables = {
      # Jupyter configuration
      JUPYTER_CONFIG_DIR = "$HOME/.config/jupyter";
      JUPYTER_DATA_DIR = "$HOME/.local/share/jupyter";
      
      # Python environment settings
      PYTHONPATH = "${pythonEnv}/${pythonEnv.sitePackages}";
      PYTHONNOUSERSITE = "1";  # Ignore user site-packages
      PYTHONHASHSEED = "0";    # Deterministic hashing
      PYTHONUNBUFFERED = "1";  # Unbuffered output
      PYTHONDONTWRITEBYTECODE = "1";  # Don't write .pyc files
      
      # Performance settings
      PYTHONOPTIMIZE = "1";    # Enable basic optimizations
      PYTHONMALLOC = "pymalloc";  # Use Python's memory allocator
      
      # Error handling
      PYTHONFAULTHANDLER = "1";  # Enable fault handler
      
      # Encoding
      PYTHONIOENCODING = "utf-8";
      
      # Path prioritization
      PATH = "${pythonEnv}/bin:$PATH";
    };
  };
  
  # Directory structure
  home.file = {
    # Jupyter Notebook configuration
    ".config/jupyter/jupyter_notebook_config.py".text = jupyterConfig.notebook;
    
    # Jupyter Lab configuration  
    ".config/jupyter/jupyter_lab_config.py".text = jupyterConfig.lab;
    
    # IPython configuration
    ".config/ipython/profile_default/ipython_config.py".text = ''
      c = get_config()
      
      # Display settings
      c.InteractiveShell.colors = 'Linux'
      c.InteractiveShell.confirm_exit = False
      c.InteractiveShell.xmode = 'Context'
      
      # Editor settings
      c.InteractiveShell.editor = 'nano'
      
      # Terminal settings
      c.TerminalIPythonApp.display_banner = True
      c.TerminalInteractiveShell.highlighting_style = 'monokai'
      c.TerminalInteractiveShell.true_color = True
      
      # History settings
      c.HistoryManager.hist_file = ':memory:'  # Don't save history to disk
      
      # Performance settings
      c.InteractiveShell.cache_size = 1000
    '';
    
    # Pip configuration
    ".config/pip/pip.conf".text = ''
      [global]
      cache-dir = ~/.cache/pip
      trusted-host = pypi.org
                     pypi.python.org
                     files.pythonhosted.org
      
      [install]
      user = false
      compile = false
      optimize = 1
      
      [wheel]
      cache-dir = ~/.cache/pip/wheels
    '';
    
    # Create notebook directory
    "Documents/notebooks/README.md".text = ''
      # Jupyter Notebooks
      
      This directory contains your Jupyter notebooks.
      
      ## Quick Start
      
      1. Start Jupyter Lab: `jupyter-lab`
      2. Start Jupyter Notebook: `jupyter-notebook`
      3. Check Python environment: Run `sys.executable` in a notebook cell
      
      ## Environment Info
      
      - Python: Nix-managed optimized Python 3.11
      - Packages: Scientific computing stack (numpy, pandas, matplotlib, etc.)
      - Kernel: nix-python
    '';
    
    # Kernel specification for the Nix Python environment
    ".local/share/jupyter/kernels/nix-python/kernel.json".text = builtins.toJSON {
      argv = [
        "${pythonEnv}/bin/python"
        "-m"
        "ipykernel_launcher"
        "-f"
        "{connection_file}"
      ];
      display_name = "Nix Python 3.11";
      language = "python";
      metadata = {
        debugger = true;
      };
      env = {
        PYTHONPATH = "${pythonEnv}/${pythonEnv.sitePackages}";
        PYTHONNOUSERSITE = "1";
      };
    };
    
    # Convenient launcher scripts
    "bin/jupyter-lab".text = ''
      #!/bin/bash
      set -e
      
      # Ensure we're using the Nix Python environment
      export PATH="${pythonEnv}/bin:$PATH"
      export PYTHONPATH="${pythonEnv}/${pythonEnv.sitePackages}"
      export PYTHONNOUSERSITE=1
      
      # Create notebooks directory if it doesn't exist
      mkdir -p "$HOME/Documents/notebooks"
              jupyter = "${pythonEnv}/bin/jupyter";
      # Start Jupyter Lab
      echo "Starting Jupyter Lab with Nix Python..."
      echo "Python executable: $(which python)"
      echo "Python version: $(python --version)"
      
      exec "${pythonEnv}/bin/jupyter" lab "$@"
    '';
    
    "bin/jupyter-notebook".text = ''
      #!/bin/bash
      set -e
      
      # Ensure we're using the Nix Python environment
      export PATH="${pythonEnv}/bin:$PATH"
      export PYTHONPATH="${pythonEnv}/${pythonEnv.sitePackages}"
      export PYTHONNOUSERSITE=1
      
      # Create notebooks directory if it doesn't exist
      mkdir -p "$HOME/Documents/notebooks"
      
      # Start Jupyter Notebook
      echo "Starting Jupyter Notebook with Nix Python..."
      echo "Python executable: $(which python)"
      echo "Python version: $(python --version)"
      
      exec "${pythonEnv}/bin/jupyter" notebook "$@"
    '';
    
    # Python environment checker
    "bin/check-python-env".text = ''
      #!/bin/bash
      set -e
      
      export PATH="${pythonEnv}/bin:$PATH"
      export PYTHONPATH="${pythonEnv}/${pythonEnv.sitePackages}"
      export PYTHONNOUSERSITE=1
      
      echo "=== Python Environment Check ==="
      echo "Python executable: $(which python)"
      echo "Python version: $(python --version)"
      echo "Site packages: ${pythonEnv}/${pythonEnv.sitePackages}"
      echo ""
      echo "=== Installed Packages ==="
      python -c "
      import sys
      import pkg_resources
      
      print(f'Python path: {sys.executable}')
      print(f'Python version: {sys.version}')
      print()
      print('Key packages:')
      
      packages = ['numpy', 'pandas', 'matplotlib', 'jupyter', 'sklearn']
      for pkg in packages:
          try:
              version = pkg_resources.get_distribution(pkg).version
              print(f'  {pkg}: {version}')
          except:
              print(f'  {pkg}: Not found')
      "
      
      echo ""
      echo "=== Jupyter Kernels ==="
      "${pythonEnv}/bin/jupyter" kernelspec list
    '';
  };
  
  # Make scripts executable
  home.activation.makeScriptsExecutable = lib.hm.dag.entryAfter ["writeBoundary"] ''
    chmod +x "$HOME/bin/jupyter-lab"
    chmod +x "$HOME/bin/jupyter-notebook" 
    chmod +x "$HOME/bin/check-python-env"
  '';
  
  # Programs configuration
  programs = {
    home-manager.enable = true;
    
    # Configure bash to use the Nix Python environment
    bash = {
      enable = true;
      shellAliases = {
        python = "${pythonEnv}/bin/python";
        pip = "${pythonEnv}/bin/pip";
        jupyter = "${pythonEnv}/bin/jupyter";
        ipython = "${pythonEnv}/bin/ipython";
      };
      
      initExtra = ''
        # Nix Python environment setup
        export PATH="${pythonEnv}/bin:$PATH"
        export PYTHONPATH="${pythonEnv}/${pythonEnv.sitePackages}"
        export PYTHONNOUSERSITE=1
        
        # Jupyter shortcuts
        alias jl='jupyter-lab'
        alias jn='jupyter-notebook'
        alias pycheck='check-python-env'
      '';
    };
  };
}
