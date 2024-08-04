# Habilitar nullglob para evitar erro quando não há correspondência
setopt nullglob

# Função para encontrar o caminho do workspace mais próximo e identificar o tipo
find_workspace() {
    local dir=$PWD
    while [[ $dir != "/" ]]; do
        # Procurar por qualquer arquivo que termine com -workspace
        for workspace_file in "$dir"/.*-workspace; do
            if [[ -f "$workspace_file" ]]; then
                # Extrair o nome do workspace do nome do arquivo
                local workspace_name=$(basename "$workspace_file" | sed 's/^\.\(.*\)-workspace$/\1/')
                echo "$dir:$workspace_name"
                return
            fi
        done
        dir=$(dirname "$dir")
    done
}

# Função para ajustar o prompt
set_prompt() {
    local workspace_info=$(find_workspace)
    local workspace_dir workspace_name

    if [[ -n $workspace_info ]]; then
        # Separar o caminho do workspace e o nome
        workspace_dir="${workspace_info%%:*}"
        workspace_name="${workspace_info##*:}"

        # Verificar se o diretório atual é o mesmo que o diretório do workspace
        if [[ $PWD == "$workspace_dir" ]]; then
            # Mostrar apenas o nome do workspace
            PROMPT="%{$fg_bold[green]%}%1{➜%} %{$fg[cyan]%}[${workspace_name}]%{$reset_color%}"
        else
            # Mostrar caminho relativo ao workspace com o nome substituído
            local relative_path="${PWD#$workspace_dir/}"
            PROMPT="%{$fg_bold[green]%}%1{➜%} %{$fg[cyan]%}[${workspace_name}] ${relative_path}%{$reset_color%}"
        fi
    else
        # Mostrar caminho completo
        PROMPT="%{$fg_bold[green]%}%1{➜%} %{$fg[cyan]%}%~%{$reset_color%}"
    fi
    
    PROMPT+=' $(git_prompt_info)'
}

# Ajuste inicial do prompt
set_prompt

# Redefinir prompt em cada comando
precmd() {
    set_prompt
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

