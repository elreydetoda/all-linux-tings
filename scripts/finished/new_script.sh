#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: https://git.io/JOrCu

function write_out_file(){
        if [[ $# -lt 1 ]] ; then
                printf "Please pass at least 1 arguments: %s\n" "script name"
                return 1
        else
                new_script_name="${1}"
                cat > "${new_script_name}" <<'EOF'
#!/usr/bin/env bash

# https://elrey.casa/bash/scripting/harden
set -${-//[sc]/}eu${DEBUG+xv}o pipefail

# short url: 

function main(){
  your_function_here
}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
EOF

        fi
}

function main(){

  write_out_file "${@}"
  chmod u+x "${1}"

}

# https://elrey.casa/bash/scripting/main
if [[ "${0}" = "${BASH_SOURCE[0]:-bash}" ]] ; then
  main "${@}"
fi
