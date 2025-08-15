{ pkgs ? import <nixpkgs> {} }:

let
  # Use Python 3.12 for better package compatibility
  pythonVersion = pkgs.python313;
  
  # Create optimized Python with proper override syntax
  optimizedPython = pythonVersion.override {
    enableOptimizations = true;
    enableLTO = true;
    reproducibleBuild = false;
  };

  # Essential Python packages
  pythonEnv = optimizedPython.withPackages (ps: with ps; [
    # Jupyter ecosystem
    jupyter
    jupyterlab
    notebook
    ipython
    ipykernel
    ipywidgets
    nbconvert
    nbformat
    jupytext
    
    # Core scientific computing
    numpy
    scipy
    pandas
    matplotlib
    seaborn
    plotly
    
    # Data manipulation
    h5py
    openpyxl
    pyarrow
    polars
    
    # Development tools
    pip
    setuptools
    wheel
    pytest
    ruff
    bandit
    
    # Visualization
    pillow
    imageio
    bokeh
    
    # Performance libraries
    numba
    cython
    
    # Database connectivity
    psycopg2
    sqlalchemy
    
    # Web and utilities
    requests
    beautifulsoup4
    lxml
    tqdm
    click
    pydantic
    
    # Statistical analysis
    statsmodels
    sympy
    
    # Additional useful packages
    rich
    networkx
    
    # Scientific libraries
    scikit-learn
  ]);

in pkgs.mkShell {
  buildInputs = with pkgs; [
    optimizedPython
    pythonEnv
    
    # Essential system dependencies
    pkg-config
    libffi
    openssl
    zlib
    
    # Development tools
    git
    curl
    
    # Graphics libraries for matplotlib/plotting
    cairo
    pango
    gdk-pixbuf
    gobject-introspection
    fontconfig
    freetype
    
    # Mathematical libraries - these will benefit from native compilation
    blas
    lapack
    openblas
    gfortran
    
    # Database libraries
    postgresql
    sqlite
    
    # Compression libraries
    bzip2
    xz
    lz4
    zstd
    
    # SSL certificates
    cacert
    
    # Performance libraries
    jemalloc
  ];

  # Native compilation environment variables
  # This is the correct way to enable -march=native for shell.nix
  NIX_CFLAGS_COMPILE = "-march=native -O3 -pipe -flto=auto -fomit-frame-pointer";
  NIX_CXXFLAGS_COMPILE = "-march=native -O3 -pipe -flto=auto -fomit-frame-pointer"; 
  NIX_LDFLAGS = "-Wl,-O1 -Wl,--as-needed";
  
  # Set compile flags for any local compilations
  CFLAGS = "-march=native -O3 -pipe -flto=auto -fomit-frame-pointer";
  CXXFLAGS = "-march=native -O3 -pipe -flto=auto -fomit-frame-pointer";
  LDFLAGS = "-Wl,-O1 -Wl,--as-needed";
  
  # Python-specific compilation flags for packages that compile native extensions
  CPPFLAGS = "-I${pkgs.python313}/include/python3.13";

  # Environment setup with native compilation awareness
  shellHook = ''
    echo "🚀 Native-Optimized Python $(python --version | cut -d' ' -f2) Environment"
    echo "🔧 Native compilation flags: -march=native -mtune=native -O3"
    echo "📊 Jupyter Lab: $(jupyter --version 2>/dev/null | head -1 || echo 'Available')"
    echo ""
    echo "⚠️  NOTE: Packages installed via pip will be compiled with native optimizations"
    echo "   Pre-built packages from nixpkgs use standard optimizations for compatibility"
    echo ""
    
    # CPU information
    echo "🖥️  CPU Information:"
    if command -v lscpu >/dev/null 2>&1; then
        echo "   $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
        echo "   $(lscpu | grep 'Architecture' | cut -d':' -f2 | xargs) architecture"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "   $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'macOS system')"
    fi
    echo ""
    
    # Performance optimizations - use all available cores
    export OPENBLAS_NUM_THREADS=''${OPENBLAS_NUM_THREADS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)}
    export MKL_NUM_THREADS=''${MKL_NUM_THREADS:-$OPENBLAS_NUM_THREADS}
    export NUMEXPR_NUM_THREADS=''${NUMEXPR_NUM_THREADS:-$OPENBLAS_NUM_THREADS}
    export OMP_NUM_THREADS=''${OMP_NUM_THREADS:-$OPENBLAS_NUM_THREADS}
    export BLIS_NUM_THREADS=''${BLIS_NUM_THREADS:-$OPENBLAS_NUM_THREADS}
    
    # Use jemalloc for better memory allocation performance
    if [[ -f "${pkgs.jemalloc}/lib/libjemalloc.so" ]]; then
        export LD_PRELOAD="''${LD_PRELOAD:+$LD_PRELOAD:}${pkgs.jemalloc}/lib/libjemalloc.so"
        export MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:30000,muzzy_decay_ms:30000"
    fi
    
    # Python performance optimizations
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONUNBUFFERED=1
    export PYTHONPATH="$PWD:$PYTHONPATH"
    export PYTHONHASHSEED=random
    
    # Ensure pip uses our compilation flags for native extensions
    export CC="gcc"
    export CXX="g++"
    
    # Jupyter configuration
    export JUPYTER_PATH="$PWD/.jupyter:$JUPYTER_PATH"
    export JUPYTER_CONFIG_DIR="$PWD/.jupyter"
    
    # Create jupyter config directory
    mkdir -p .jupyter
    
    # Install IPython kernel with native optimization info
    if ! jupyter kernelspec list 2>/dev/null | grep -q "python3-native"; then
        python -m ipykernel install --user --name=python3-native --display-name="Python 3 (Native Ready)" 2>/dev/null || true
    fi
    
    # Display active compilation environment
    echo "🔧 Active Compilation Environment:"
    echo "   CC: $(which gcc 2>/dev/null || echo 'gcc (from nixpkgs)')"
    echo "   CFLAGS: $CFLAGS"
    echo "   Threads: $OPENBLAS_NUM_THREADS cores"
    if [[ -n "''${LD_PRELOAD:-}" ]]; then
        echo "   Memory: jemalloc enabled"
    fi
    echo ""
    
    echo "🚀 Environment ready! Available commands:"
    echo "  jupyter lab          - Start JupyterLab"
    echo "  jupyter notebook     - Start Jupyter Notebook"
    echo "  ipython             - Start IPython shell"
    echo "  python              - Start Python interpreter"
    echo "  pip install <pkg>    - Install packages with native compilation"
    echo ""
    echo "📦 Pre-installed Packages:"
    echo "  Scientific: numpy, scipy, pandas, scikit-learn, matplotlib"
    echo "  Performance: numba, cython, openblas"
    echo "  Jupyter: jupyterlab, notebook, ipython, ipywidgets"
    echo "  Development: black, pytest, mypy, flake8"
    echo "  Data: h5py, pyarrow, polars, psycopg2"
    echo ""
    echo "💡 Tip: Any pip-installed packages will be compiled with -march=native for your CPU!"
  '';

  # Enhanced library paths for native-compiled extensions
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.libffi
    pkgs.openssl
    pkgs.blas
    pkgs.lapack
    pkgs.openblas
    pkgs.gfortran.cc.lib
    pkgs.jemalloc
  ];
  
  # PKG_CONFIG_PATH for building native extensions
  PKG_CONFIG_PATH = pkgs.lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
    pkgs.libffi
    pkgs.openssl
    pkgs.zlib
    pkgs.openblas
  ];
}
