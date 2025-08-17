{ pkgs, lib, config, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      font = "Ubuntu Nerd Font 13";
      adjust-open = "best-fit";
      selection-clipboard = "clipboard";
      window-title-basename = "true";
      pages-per-row = "1";
      scroll-page-aware = "true";
      scroll-full-overlap = "0.01";
      scroll-step = "100";
      smooth-scroll = true;
      zoom-min = "10";
      recolor = true;
      statusbar-h-padding = 10;
      statusbar-v-padding = 10;

      default-fg = "#CDD6F4";
      default-bg = "#1E1E2E";

      completion-bg = "#313244";
      completion-fg = "#CDD6F4";
      completion-highlight-bg = "#575268";
      completion-highlight-fg = "#CDD6F4";
      completion-group-bg = "#313244";
      completion-group-fg = "#89B4FA";

      statusbar-fg = "#CDD6F4";
      statusbar-bg = "#313244";

      notification-bg	= "#313244";
      notification-fg	= "#CDD6F4";
      notification-error-bg =	"#313244";
      notification-error-fg	= "#F38BA8";
      notification-warning-bg =	"#313244";
      notification-warning-fg	= "#FAE3B0";

      inputbar-fg =	"#CDD6F4";
      inputbar-bg =	"#313244";

      recolor-lightcolor = "#1E1E2E";
      recolor-darkcolor	=	"#CDD6F4";

      index-fg = "#CDD6F4";
      index-bg = "#1E1E2E";
      index-active-fg =	"#CDD6F4";
      index-active-bg	=	"#313244";

      render-loading-bg =	"#1E1E2E";
      render-loading-fg	=	"#CDD6F4";

      highlight-color =	"#575268";
      highlight-fg = "#F5C2E7";
      highlight-active-color = "#F5C2E7";
      render-loading = true;

    };
  };
}
