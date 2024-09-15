# AwesomeVim - NeoVim Config for Power Users

![Copy of White Minimalist Profile LinkedIn Banner](https://github.com/user-attachments/assets/4e42b971-35c0-4a91-98d0-f108e2e440f1)

A customizable, fast, and modern Neovim configuration built for an optimal coding experience. Awesome Vim combines powerful features, intuitive keybindings, and popular plugins to create a delightful coding environment. Built upon Vanilla NeoVim, it's fast and flexible for customizations. Its one command installation allows busy developers to set up a fully functional NeoVim code editor on the go without manually installing the most and leverage more than what Vanilla NeoVim can provide. 

## Installation 

Awesome Vim has minimal demands before getting started. You must have the following things installed on your system. 

- **Git**: Version control system
- **Bash**: Unix shell and command language
- **Curl**: Command-line tool for transferring data with URLs
- **GCC**: GNU Compiler Collection (for compiling plugins, etc.)
- **NeoVim**: Version **0.5** or later (required for Lua-based configuration and plugins)

All of the packages are available in most package managers, such as Apt, Brew, Pacman, etc. 

### Single-line Command

Copy and Paste this single-line command into your terminal. It's a bash script compatible with Linux, MacOS, and WSL on Windows. 

```
curl https://raw.githubusercontent.com/PythonHacker24/awesomevim/main/install.sh | bash 
```
Note: This script is under development and may face issues. In that case, use the source code method or create an issue in the [issues tab](https://github.com/PythonHacker24/awesomevim/issues)

### Through Source Code 

1. Clone the repository and save it as .config/nvim
2. Install Packer: `git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim`. For more info, visit [Packer GitHub](https://github.com/wbthomason/packer.nvim)
3. Navigate to .config/nvim/custom and do `nv packer.lua`. Ignore all the errors. 
4. So `:so` to source the file.
5. Do `:PackerSync` to install and sync all the plugins. Done!

## Features 

- Blazingly Fast: Packed with the most optimal stuff and minimal plugins installed to make it bloat-free. You can add as many plugins as you want through Packer in an easy way.
- LSP Ready: Built-in support for Language Server Protocol for auto-completion, linting, and more.
- Tree-sitter Support: Enhanced syntax highlighting and code folding.
- Integrated Git: Seamless git integration with fugitive and other git utilities.
- Telescope: Fuzzy finder for files, buffers, and much more.
- Beautiful Theme: Uses a modern, eye-friendly color scheme like Catpuccin Mocha and Nord.

## Screenshots 

<img width="1470" alt="Screenshot 2024-06-21 at 13 01 01" src="https://github.com/user-attachments/assets/738e66ba-6483-4e8a-8590-d5e56cb17ef8">

<img width="1470" alt="Screenshot 2024-06-22 at 18 10 41" src="https://github.com/user-attachments/assets/5e977765-4ed3-42f9-bd61-ab4fc42437b9">

## Default Plugins Installed 

All the plugins are managed with Packer.nvim. Here are a few must-have plugins installed on Awesome Vim. 

## Key Plugins

Here’s an overview of the main plugins included in this configuration:

- **[packer.nvim](https://github.com/wbthomason/packer.nvim)**: Plugin manager for NeoVim.
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)**: Enhanced syntax highlighting, powered by Tree-sitter.
- **[Telescope](https://github.com/nvim-telescope/telescope.nvim)**: Fuzzy file finder and more.
- **[neoscroll.nvim](https://github.com/karb94/neoscroll.nvim)**: Smooth scrolling experience.
- **[lsp-zero](https://github.com/VonHeikemen/lsp-zero.nvim)**: LSP configuration with autocompletion.
- **[nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)**: File explorer.
- **[toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)**: Toggleable terminal inside NeoVim.
- **[harpoon](https://github.com/ThePrimeagen/harpoon)**: Quick navigation between files.
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)**: Statusline plugin.
- **[startup.nvim](https://github.com/startup-nvim/startup.nvim)**: Startup screen customizer.
- **Themes**: Choose between [catppuccin](https://github.com/catppuccin/nvim) or [nord-vim](https://github.com/arcticicestudio/nord-vim) for modern color schemes.

## Adding More Packages

This configuration uses [packer.nvim](https://github.com/wbthomason/packer.nvim) as the plugin manager. To add more packages or plugins, follow these steps:

1. **Open your `init.lua` or `plugins.lua` file** where the plugins are managed.

2. **Add your desired plugin** inside the `packer.startup(function(use)` block. For example, to add a new plugin:

   ```lua
   use 'author/plugin-name'
   ```
3. **Open custom/packer.lua with Awesome Vim** and source the fil:
  ```
  :so
  ```
4. **Finally do PackerSynce**:
  ```
  :PackerSync
  ```

## Key Bindings

This configuration includes custom keybindings to enhance productivity in NeoVim:

| Keybinding           | Action                                     |
|----------------------|--------------------------------------------|
| `<leader>` (Space)   | The leader key is set to `Space`           |
| `<leader>f`          | Open Telescope (Fuzzy Finder)              |
| `<leader>h`          | Toggle Terminal (ToggleTerm)               |
| `<C-n>`              | Toggle NvimTree (File Explorer)            |
| `<C-w>v`             | Split window vertically                    |
| `<C-w>n`             | Split window horizontally                  |
| `<C-u>`              | Scroll up half a page smoothly             |
| `<C-d>`              | Scroll down half a page smoothly           |
| `<C-b>`              | Scroll up one full page smoothly           |
| `<C-f>`              | Scroll down one full page smoothly         |
| `<C-y>`              | Scroll up one line smoothly                |
| `<C-e>`              | Scroll down one line smoothly              |
| `zt`                 | Smoothly scroll to the top of the screen   |
| `zz`                 | Smoothly center the cursor on the screen   |
| `zb`                 | Smoothly scroll to the bottom of the screen|

## Bug Reports

If you encounter any issues or bugs while using this configuration, please follow these steps to report them:

1. **Check Existing Issues**: Before opening a new issue, please check the [Issues](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY/issues) tab to see if the problem has already been reported.

2. **Provide Detailed Information**: When creating a new issue, please include the following details to help diagnose the problem:
   - A clear and descriptive title.
   - Steps to reproduce the issue.
   - Any error messages or logs (you can check `:messages` in NeoVim).
   - Your operating system and NeoVim version (`nvim --version`).
   - A list of any modifications you made to the configuration.

3. **Submit the Issue**: Once you've gathered the necessary information, open a [new issue](https://github.com/YOUR_USERNAME/YOUR_REPOSITORY/issues/new) and provide all relevant details.

This will help us to identify and fix the issue quickly. Pull requests are also welcome!

## License
This project is licensed under the [MIT License](LICENSE). 

