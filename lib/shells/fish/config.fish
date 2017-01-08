# Loads Dot runtime for a user running the Fish shell.
#
# Your ~/.config/fish/config.fish should be a symlink to this file.
#
# Do not make changes to this file -- use Dot plugins!

set -x DOT_FRAMEWORK_DIR (cd (dirname (dirname (dirname (readlink "$0")))); and pwd)
set -x DOT_HOME (dirname (readlink "$DOT_FRAMEWORK_DIR"))

set -x DOT_SHELL fish
set -x DOT_BACKUPS_DIR $DOT_HOME/.backups
set -x DOT_PLUGINS_DIR $DOT_HOME/plugins
set -x DOT_PATH_DIR $DOT_HOME/.path

set -x PATH $DOT_PATH_DIR $PATH

# Filter plugins not supported by the current OS
set plugins
for plugin in (dot::plugins::dependency_order)
  if ! dot::plugin::platform_supported
    continue
  end

  set plugins $plugins $plugin

  set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin
  for script in $DOT_PLUGIN_DIR/lib/*.$DOT_SHELL
    if ! source $script
      echo "ERROR: Problem sourcing script $script for plugin $plugin_name"
      exit 1
    end
  end
done

if status --is-login
  for plugin in $plugins
    set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin

    for script in $DOT_PLUGIN_DIR/lib/login/*.$DOT_SHELL
      if ! source $script
        echo "ERROR: Problem sourcing login script $script for plugin $plugin"
        exit 1
      end
    end
  done

  # Callback that is executed when shell exits
  function dot::logout --on-process %self
    for plugin in $plugins
      set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin

      for script in $DOT_PLUGIN_DIR/lib/logout/*.$DOT_SHELL
        if ! source $script
          echo "ERROR: Problem sourcing logout script $script for plugin $plugin"
          exit 1
        end
      end
    done
  end
end

if status --is-interactive
  for plugin in $plugins
    set DOT_PLUGIN_DIR $DOT_PLUGINS_DIR/$plugin_name

    for script in $DOT_PLUGIN_DIR/lib/interactive/*.$DOT_SHELL
      if ! source $script
        echo "ERROR: Problem sourcing interactive script $script for plugin $plugin"
        exit 1
      end
    end
  done
end
