if ! $(type __set_custom_path 1>/dev/null 2>&1)
then
    function __set_custom_path()
    {
        echo "-- Calling '${FUNCTION[0]}'."
        
        export UNTOUCHED_PATH="${PATH}"
        export PATH="${HOME}/Workspace/toolbox/scripts:${PATH}"
    }
    __set_custom_path
fi
