# Loads Dot runtime for a user running the Fish shell.
#
# Your ~/.config/fish/config.fish should be a symlink to this file.
#
# Do not make changes to this file -- use Dot plugins!

set __file__ $HOME/.config/fish/config.fish

set -x DOT_FRAMEWORK_DIR (dirname (dirname (dirname (dirname (readlink $__file__)))))
set -x DOT_HOME (dirname $DOT_FRAMEWORK_DIR)

set -x DOT_SHELL fish
set -x DOT_BACKUPS_DIR $DOT_HOME/.backups
set -x DOT_PLUGINS_DIR $DOT_HOME/plugins
set -x DOT_PATH_DIR $DOT_HOME/.path

set -x PATH $DOT_FRAMEWORK_DIR/libexec $PATH
set -x PATH $DOT_PATH_DIR $PATH

set DOT_PLUGINS_DEPENDENCY_ORDER (cat $DOT_HOME/.cache/plugin_load_order)

source "$DOT_FRAMEWORK_DIR/lib/shells/fish/load_env"

set plugins
for plugin in $DOT_PLUGINS_DEPENDENCY_ORDER
  set plugins $plugins $plugin

  set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin

  for env_path in $DOT_PLUGIN_DIR/env/*
    if [ -f $env_path ]
      if not load_env $env_path
        echo "ERROR: Failed to load environment variables $env_path for plugin $plugin. Halting"
        exit 1
      end
    end
  end

  for script in $DOT_PLUGIN_DIR/lib/*.fish
    if not source $script
      echo "ERROR: Problem sourcing script $script for plugin $plugin_name"
      exit 1
    end
  end
end

if status --is-login
  for plugin in $plugins
    set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin

    for env_path in $DOT_PLUGIN_DIR/env/login/*
      if [ -f $env_path ]
        if not load_env $env_path
          echo "ERROR: Failed to load environment variables $env_path for plugin $plugin. Halting"
          exit 1
        end
      end
    end

    for script in $DOT_PLUGIN_DIR/lib/login/*.fish
      if not source $script
        echo "ERROR: Problem sourcing login script $script for plugin $plugin"
        exit 1
      end
    end
  end

  # Callback that is executed when shell exits
  function dot::logout --on-process %self
    for plugin in $plugins
      set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin

      for script in $DOT_PLUGIN_DIR/lib/logout/*.fish
        if not source $script
          echo "ERROR: Problem sourcing logout script $script for plugin $plugin"
          exit 1
        end
      end
    end
  end
end

if status --is-interactive
  for plugin in $plugins
    set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin

    for env_path in $DOT_PLUGIN_DIR/env/interactive/*
      if [ -f $env_path ]
        if not load_env $env_path
          echo "ERROR: Failed to load environment variables $env_path for plugin $plugin. Halting"
          exit 1
        end
      end
    end

    for script in $DOT_PLUGIN_DIR/lib/interactive/*.fish
      if not source $script
        echo "ERROR: Problem sourcing interactive script $script for plugin $plugin"
        exit 1
      end
    end
  end
end
