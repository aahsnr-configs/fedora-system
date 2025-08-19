# ~/.config/home-manager/eza/default.nix
{ ... }: {
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "always";
    git = true;
    extraOptions = [ "--group-directories-first" "--header" ];
    # Catppuccin Mocha Theme for eza
    # Translated from your theme.yml into idiomatic Nix.
    # Color palette: https://github.com/catppuccin/catppuccin
    theme = {
      # UI elements
      ui = {
        size = {
          number = "#fab387"; # Peach
          unit = "#f38ba8"; # Red
        };
        user = "#f9e2af"; # Yellow
        group = "#a6e3a1"; # Green
        date = {
          day = "#89b4fa"; # Blue
          time = "#cba6f7"; # Mauve
        };
        inode = "#cdd6f4"; # Text
        blocks = "#fab387"; # Peach
        header = "#b4befe"; # Lavender
        links = "#f5e0dc"; # Rosewater
        tree = "#cba6f7"; # Mauve
      };

      # Punctuation and symbols
      punctuation = "#9399b2"; # Overlay2

      # File permissions
      permission = {
        read = "#a6e3a1"; # Green
        write = "#f9e2af"; # Yellow
        exec = "#f38ba8"; # Red
        exec_sticky = "#cba6f7"; # Mauve
        no_access = "#6c7086"; # Surface0
        octal = "#fab387"; # Peach
        attribute = "#89dceb"; # Sky
      };

      # File type colors (subset)
      filetype = {
        # Directories and special files
        directory = "#89b4fa"; # Blue
        # NOTE: 'executable' is handled by 'filekinds' below.

        # Links and pipes
        symlink = "#89dceb"; # Sky
        pipe = "#f5c2e7"; # Pink
        socket = "#f5c2e7"; # Pink
        block_device = "#f38ba8"; # Red
        char_device = "#f38ba8"; # Red

        # Special permissions
        setuid = "#fab387"; # Peach
        setgid = "#fab387"; # Peach
        sticky = "#89b4fa"; # Blue
        other_writable = "#89b4fa"; # Blue
        sticky_other_writable = "#cba6f7"; # Mauve
      };

      # File kinds (modern classification)
      filekinds = {
        image = "#94e2d5"; # Teal
        video = "#74c7ec"; # Sapphire
        music = "#cba6f7"; # Mauve
        lossless = "#cba6f7"; # Mauve
        crypto = "#f38ba8"; # Red
        document = "#f5c2e7"; # Pink
        compressed = "#fab387"; # Peach
        temp = "#6c7086"; # Surface0
        compiled = "#fab387"; # Peach
        source = "#89b4fa"; # Blue
        executable = "#a6e3a1"; # Green
      };

      # Git integration
      git = {
        clean = "#a6e3a1"; # Green
        new = "#89b4fa"; # Blue
        modified = "#f9e2af"; # Yellow
        deleted = "#f38ba8"; # Red
        renamed = "#cba6f7"; # Mauve
        typechange = "#fab387"; # Peach
        ignored = "#6c7086"; # Surface0
        conflicted = "#eba0ac"; # Maroon
      };

      # Security context colors
      security_context = {
        colon = "#cdd6f4"; # Text
        user = "#f9e2af"; # Yellow
        role = "#a6e3a1"; # Green
        type = "#89b4fa"; # Blue
        range = "#cba6f7"; # Mauve
      };

      # Extension-based colors
      extension = {
        # Archives and compressed files
        "7z" = "#fab387";
        ace = "#fab387";
        alz = "#fab387";
        arc = "#fab387";
        arj = "#fab387";
        bz = "#fab387";
        bz2 = "#fab387";
        cab = "#fab387";
        cpio = "#fab387";
        deb = "#fab387";
        dmg = "#fab387";
        dz = "#fab387";
        ear = "#fab387";
        esd = "#fab387";
        gz = "#fab387";
        jar = "#fab387";
        lha = "#fab387";
        lrz = "#fab387";
        lz = "#fab387";
        lz4 = "#fab387";
        lzh = "#fab387";
        lzma = "#fab387";
        lzo = "#fab387";
        rar = "#fab387";
        rpm = "#fab387";
        rz = "#fab387";
        sar = "#fab387";
        srpm = "#fab387";
        swm = "#fab387";
        t7z = "#fab387";
        tar = "#fab387";
        taz = "#fab387";
        tbz = "#fab387";
        tbz2 = "#fab387";
        tgz = "#fab387";
        tlz = "#fab387";
        txz = "#fab387";
        tz = "#fab387";
        tzo = "#fab387";
        tzst = "#fab387";
        war = "#fab387";
        wim = "#fab387";
        xz = "#fab387";
        z = "#fab387";
        zip = "#fab387";
        zoo = "#fab387";
        zst = "#fab387";

        # Package formats
        appimage = "#fab387";
        flatpak = "#fab387";
        snap = "#fab387";
        pkg = "#fab387";
        msi = "#fab387";

        # Images
        avif = "#94e2d5";
        bmp = "#94e2d5";
        cgm = "#94e2d5";
        emf = "#94e2d5";
        gif = "#94e2d5";
        heic = "#94e2d5";
        heif = "#94e2d5";
        ico = "#94e2d5";
        jpeg = "#94e2d5";
        jpg = "#94e2d5";
        mjpeg = "#94e2d5";
        mjpg = "#94e2d5";
        mng = "#94e2d5";
        pbm = "#94e2d5";
        pcx = "#94e2d5";
        pgm = "#94e2d5";
        png = "#94e2d5";
        ppm = "#94e2d5";
        svg = "#94e2d5";
        svgz = "#94e2d5";
        tga = "#94e2d5";
        tif = "#94e2d5";
        tiff = "#94e2d5";
        webp = "#94e2d5";
        xbm = "#94e2d5";
        xcf = "#94e2d5";
        xpm = "#94e2d5";
        xwd = "#94e2d5";

        # Videos
        asf = "#74c7ec";
        avi = "#74c7ec";
        dl = "#74c7ec";
        flc = "#74c7ec";
        fli = "#74c7ec";
        flv = "#74c7ec";
        gl = "#74c7ec";
        m2v = "#74c7ec";
        m4v = "#74c7ec";
        mkv = "#74c7ec";
        mov = "#74c7ec";
        mp4 = "#74c7ec";
        mp4v = "#74c7ec";
        mpeg = "#74c7ec";
        mpg = "#74c7ec";
        nuv = "#74c7ec";
        ogm = "#74c7ec";
        ogv = "#74c7ec";
        ogx = "#74c7ec";
        qt = "#74c7ec";
        rm = "#74c7ec";
        rmvb = "#74c7ec";
        vob = "#74c7ec";
        webm = "#74c7ec";
        wmv = "#74c7ec";
        yuv = "#74c7ec";

        # Audio
        aac = "#cba6f7";
        au = "#cba6f7";
        flac = "#cba6f7";
        m4a = "#cba6f7";
        mid = "#cba6f7";
        midi = "#cba6f7";
        mka = "#cba6f7";
        mp3 = "#cba6f7";
        mpc = "#cba6f7";
        oga = "#cba6f7";
        ogg = "#cba6f7";
        opus = "#cba6f7";
        ra = "#cba6f7";
        spx = "#cba6f7";
        wav = "#cba6f7";
        wma = "#cba6f7";
        xspf = "#cba6f7";

        # Documents
        doc = "#f5c2e7";
        docx = "#f5c2e7";
        epub = "#f5c2e7";
        md = "#f5c2e7";
        markdown = "#f5c2e7";
        mobi = "#f5c2e7";
        odt = "#f5c2e7";
        odp = "#f5c2e7";
        ods = "#f5c2e7";
        pdf = "#f5c2e7";
        ppt = "#f5c2e7";
        pptx = "#f5c2e7";
        ps = "#f5c2e7";
        rst = "#f5c2e7";
        rtf = "#f5c2e7";
        tex = "#f5c2e7";
        xls = "#f5c2e7";
        xlsx = "#f5c2e7";

        # Text files
        diff = "#cdd6f4";
        log = "#a6adc8";
        out = "#a6adc8";
        patch = "#cdd6f4";
        txt = "#cdd6f4";

        # Configuration files
        cfg = "#94e2d5";
        conf = "#94e2d5";
        desktop = "#94e2d5";
        ini = "#94e2d5";
        json = "#f9e2af";
        rc = "#94e2d5";
        service = "#94e2d5";
        target = "#94e2d5";
        timer = "#94e2d5";
        toml = "#f9e2af";
        xml = "#f9e2af";
        yaml = "#f9e2af";
        yml = "#f9e2af";

        # Programming languages
        bash = "#a6e3a1";
        c = "#89b4fa";
        cc = "#89b4fa";
        clj = "#a6e3a1";
        cljs = "#a6e3a1";
        cpp = "#89b4fa";
        cs = "#cba6f7";
        csh = "#a6e3a1";
        cxx = "#89b4fa";
        dart = "#89b4fa";
        fish = "#a6e3a1";
        fs = "#cba6f7";
        go = "#89dceb";
        h = "#89b4fa";
        hpp = "#89b4fa";
        java = "#fab387";
        js = "#f9e2af";
        jsx = "#89b4fa";
        ksh = "#a6e3a1";
        kt = "#fab387";
        lua = "#89b4fa";
        perl = "#89b4fa";
        php = "#cba6f7";
        pl = "#89b4fa";
        py = "#f9e2af";
        r = "#89b4fa";
        rb = "#f38ba8";
        rs = "#fab387";
        scala = "#f38ba8";
        sh = "#a6e3a1";
        swift = "#fab387";
        tcsh = "#a6e3a1";
        ts = "#89b4fa";
        tsx = "#89b4fa";
        vb = "#cba6f7";
        vue = "#a6e3a1";
        zig = "#fab387";
        zsh = "#a6e3a1";

        # Web files
        css = "#89b4fa";
        htm = "#fab387";
        html = "#fab387";
        less = "#89b4fa";
        sass = "#f5c2e7";
        scss = "#f5c2e7";
        styl = "#89b4fa";

        # Database files
        db = "#f9e2af";
        sql = "#f9e2af";
        sqlite = "#f9e2af";
        sqlite3 = "#f9e2af";

        # Fedora specific files
        kickstart = "#f38ba8";
        ks = "#f38ba8";
        repo = "#89b4fa";
        spec = "#a6e3a1";

        # Container files
        containerfile = "#89dceb";
        "docker-compose" = "#89dceb";
        dockerfile = "#89dceb";

        # Executables
        bin = "#a6e3a1";
        exe = "#a6e3a1";
        run = "#a6e3a1";

        # Temporary/backup files
        "~" = "#6c7086";
        bak = "#6c7086";
        backup = "#6c7086";
        orig = "#6c7086";
        rej = "#6c7086";
        swo = "#6c7086";
        swp = "#6c7086";
        temp = "#6c7086";
        tmp = "#6c7086";
      };
    };
  };

  programs.zsh.shellAliases = {
    # Override default eza aliases to add more options
    ls = "eza --color=always --icons=always --group-directories-first";
    ll =
      "eza -l --color=always --icons=always --group-directories-first --git --header";
    la =
      "eza -la --color=always --icons=always --group-directories-first --git --header";
    lt =
      "eza --tree --color=always --icons=always --group-directories-first --level=3";

    # Custom aliases from eza.zsh
    lr = "eza -R --color=always --icons=always --group-directories-first";
    lg =
      "eza -l --git --git-ignore --color=always --icons=always --group-directories-first --header";
    lG =
      "eza -l --git --git-ignore --git-repos --color=always --icons=always --group-directories-first --header";
    lsize =
      "eza -l --sort=size --reverse --color=always --icons=always --group-directories-first --git --header";
    ltime =
      "eza -l --sort=modified --reverse --color=always --icons=always --group-directories-first --git --header";
    lrpm = ''
      eza -la --color=always --icons=always *.rpm *.srpm 2>/dev/null || echo "No RPM files found"'';
    lspec = ''
      eza -la --color=always --icons=always *.spec 2>/dev/null || echo "No spec files found"'';
    lz =
      "eza -la --color=always --icons=always --group-directories-first --context";
    lsystemd-system =
      "eza -la --color=always --icons=always /etc/systemd/system/";
    lsystemd-user =
      "eza -la --color=always --icons=always ~/.config/systemd/user/";
  };

  programs.zsh.initContent = ''
    # Eza helper functions
    ezasize() {
        eza -l --color=always --icons=always --group-directories-first --total-size --color-scale=size --sort=size --reverse "$@"
    }
    ezarecent() {
        local days=''${1:-7}
        eza -la --color=always --icons=always --sort=modified --reverse --color-scale=age "$@" | head -20
    }
    ezatree() {
        local depth=''${1:-3}
        shift
        eza --tree --color=always --icons=always --group-directories-first --level="$depth" --ignore-glob=".git|node_modules|.cache" "$@"
    }
    ezaperm() {
        eza -la --color=always --icons=always --group-directories-first --octal-permissions "$@"
    }
  '';
}
