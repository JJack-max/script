# Flutter Version Management (FVM)

FVM is a simple CLI tool to manage multiple Flutter versions on your machine.

## Common FVM Commands

### Install FVM

```bash
dart pub global activate fvm
```

### Initialize FVM in Project

```bash
fvm init
```

### View Available Releases

```bash
# List all available Flutter releases
fvm releases

# List releases with specific channel
fvm releases --channel stable
fvm releases --channel beta
fvm releases --channel dev
```

### Install Flutter Versions

```bash
# Install the latest stable version
fvm install stable

# Install a specific version
fvm install 3.10.0

# Install beta channel
fvm install beta
```

### Set Project Flutter Version

```bash
# Use a specific version for the current project
fvm use 3.10.0

# Use stable channel for the current project
fvm use stable
```

### List Installed Versions

```bash
fvm list
```

### Check Current Version

```bash
fvm current
```

### Upgrade Flutter Version

```bash
# Upgrade the current channel
fvm upgrade

# Upgrade a specific version
fvm upgrade 3.10.0
```

### Remove Flutter Version

```bash
fvm remove 3.10.0
```

### Run Commands with Specific Version

```bash
# Run Flutter commands with a specific version
fvm flutter doctor
fvm flutter pub get
fvm dart analyze
```

### Global Version Settings

```bash
# Set global Flutter version
fvm global stable

# Check global version
fvm global
```

## Using FVM as a Complete Replacement for Flutter Commands

Yes, you can completely replace direct `flutter` commands with FVM equivalents. This is actually recommended as it ensures you're always using the correct Flutter version for each project:

### Direct Command Substitution

```bash
# Instead of: flutter doctor
fvm flutter doctor

# Instead of: flutter pub get
fvm flutter pub get

# Instead of: flutter run
fvm flutter run

# Instead of: flutter build apk
fvm flutter build apk

# Instead of: flutter test
fvm flutter test

# Instead of: dart analyze
fvm dart analyze

# Instead of: dart format lib/
fvm dart format lib/
```

### Benefits of Using FVM Commands

1. **Version Consistency**: Ensures you're always using the correct Flutter version for each project
2. **No PATH Issues**: No need to configure PATH variables or deal with global Flutter installations
3. **Project Isolation**: Each project can use a different Flutter version without conflicts
4. **Team Consistency**: All team members use the same Flutter version as defined in the project

### Creating Aliases (Optional)

If you prefer shorter commands, you can create aliases in your shell profile:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias flutter='fvm flutter'
alias dart='fvm dart'

# Then you can use normal commands but they will be routed through FVM
# flutter doctor
# dart analyze
```

## Troubleshooting

### Flutter Commands Not Found After Installation

If you've installed Flutter using FVM but the `flutter` command is not found, it's likely due to PATH configuration issues:

1. **Add FVM cache path to your shell profile:**

   ```bash
   # For Bash (~/.bashrc or ~/.bash_profile)
   export PATH="$PATH:$HOME/fvm/default/bin"

   # For Zsh (~/.zshrc)
   export PATH="$PATH:$HOME/fvm/default/bin"

   # For Fish (~/.config/fish/config.fish)
   set -gx PATH $PATH $HOME/fvm/default/bin
   ```

2. **Alternative: Use FVM's built-in path command:**

   ```bash
   # Add this to your shell profile to automatically configure PATH
   export PATH="$PATH:`fvm config --cache-path`/default/bin"
   ```

3. **Restart your terminal or source your profile:**

   ```bash
   # For Bash
   source ~/.bashrc

   # For Zsh
   source ~/.zshrc
   ```

4. **Verify installation:**

   ```bash
   # Check if FVM is correctly configured
   fvm doctor

   # List installed versions
   fvm list
   ```

5. **If still not working, manually link the version:**

   ```bash
   # Link a specific version as default
   fvm global stable

   # Or link to a specific version
   fvm global 3.10.0
   ```

### FVM Warning About Incorrect Flutter Path

If you see a warning like:

```
┌───────────────────────────────────────────────────────┐
│ ⚠ However your configured "flutter" path is incorrect │
└───────────────────────────────────────────────────────┘
CURRENT: No version is configured on path.
CHANGE TO: /root/fvm/default/bin
```

This means FVM has set the Flutter version but your shell doesn't know where to find the `flutter` command. You need to update your PATH:

1. **Export the correct PATH:**

   ```bash
   # Use the path suggested by FVM (in your case)
   export PATH="$PATH:/root/fvm/default/bin"

   # Or use FVM's config to get the cache path dynamically
   export PATH="$PATH:`fvm config --cache-path`/default/bin"
   ```

2. **Make it permanent by adding to your shell profile:**

   ```bash
   # Add to ~/.bashrc, ~/.zshrc, or appropriate shell config file
   echo 'export PATH="$PATH:/root/fvm/default/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Alternative solution - use FVM-wrapped commands:**
   Even if the PATH isn't configured, you can always use:
   ```bash
   fvm flutter --version
   fvm flutter doctor
   fvm flutter pub get
   ```

### Using Flutter Commands with FVM

Even if Flutter is not in your PATH, you can always use Flutter commands through FVM:

```bash
# Instead of 'flutter doctor', use:
fvm flutter doctor

# Instead of 'flutter pub get', use:
fvm flutter pub get

# Instead of 'dart analyze', use:
fvm dart analyze
```
