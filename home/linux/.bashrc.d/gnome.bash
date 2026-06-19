if ! $(type __gnome_tab_switching_behavior 1>/dev/null 2>&1)
then
    function __gnome_tab_switching_behavior()
    {
        echo "-- Calling '${FUNCTION[0]}'."
                
        gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
        gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
        gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
        gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Alt><Shift>Tab']"
    }
    __gnome_tab_switching_behavior
fi