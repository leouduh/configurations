#! /bin/bash/

set_credentials() {

tmp_profile=$1/$2

assume $tmp_profile

tmp_access_key_id=$(granted credential-process --profile $tmp_profile | sed 's/.*"AccessKeyId":"\([^"]*\).*/\1/')
tmp_secret_access_key=$(granted credential-process --profile $tmp_profile | sed 's/.*"SecretAccessKey":"\([^"]*\).*/\1/')
tmp_session_token=$(granted credential-process --profile $tmp_profile | sed 's/.*"SessionToken":"\([^"]*\).*/\1/')
rm ~/.aws/credentials
touch ~/.aws/credentials
echo "[default]" >> ~/.aws/credentials
echo "aws_access_key_id = $tmp_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key = $tmp_secret_access_key" >> ~/.aws/credentials
echo "aws_session_token = $tmp_session_token" >> ~/.aws/credentials
echo "aws_region = eu-west-2" >> ~/.aws/credentials
echo "Config set up for profile $tmp_profile"
}


configure() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: configure {sandbox|research|dev} {AWSPowerUserAccess|TEAM-DS-Diagnostic-Products|datascience-poweruser}"
    echo "ERROR: Incorrect usage expected 2 arguments"
    return 1
  else
    local environment="$1"
    local role="$2"

    echo "Configuring for environment: $environment and role: $role"

    case $environment in
      sandbox)
        echo "Haha we have found you an environment"
        local sandbox_account="jlr-gdd-vcdp-ds-$environment"
        case $role in
          datascience-poweruser)
            set_credentials $sandbox_account $2
            ;;
          *)
            echo "You have selected an invalid role '{$role}' for the environment '{$environment}'"
        esac
        ;;
      research)
        local research_account="jlr-gdd-vcdp-ds-$environment"
        case $role in
          TEAM-DS-Diagnostic-Products)
            set_credentials $research_account $2
            ;;
          *)
            echo "You have selected an invalid role '{$role}' for the environment '{$environment}'"

        esac
        ;;
      dev)
        local dev_account="vcdp-data-science-$environment"
        case $role in
          AWSPowerUserAccess)
            set_credentials $dev_account $2
            ;;
          *)
            echo "You have selected an invalid role '{$role}' for the environment '{$environment}'"

        esac
        ;;
      *)
        echo "Error: You have selected an invalid environment '${environment}' Expected sandbox research or dev"
        return 1
    esac
  fi
  return 0

}

_configure_completions(){
  local cur_word prev_word
  cur_word="${COMP_WORDS[COMP_CWORD]}"
  prev_word="${COMP_WORDS[COMP_CWORD-1]}"

  case "${COMP_CWORD}" in
    1)
      local environments="sandbox research dev"
      COMPREPLY=($(compgen -W "${environments}" -- "${cur_word}"))
      ;;
    2)
      case "${prev_word}" in
        sandbox)
          local sandbox_roles="datascience-poweruser"
          COMPREPLY=($(compgen -W "${sandbox_roles}" -- "${cur_word}"))
          ;;
        research)
          local research_roles="TEAM-DS-Diagnostic-Products"
          COMPREPLY=($(compgen -W "${research_roles}" -- "${cur_word}"))
          ;;
        dev)
          local dev_roles="AWSPowerUserAccess"
          COMPREPLY=($(compgen -W "${dev_roles}" -- "${cur_word}"))
          ;;
      esac
      ;;
  esac
}

complete -F _configure_completions configure
