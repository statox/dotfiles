workdir="$(pwd)"

[ ! -e "$HOME/.claude.json" ] && echo "{}" > "$HOME/.claude.json"
mkdir -p "${workdir}/.venv-claude"

# podman run --rm -it \
#   --userns=keep-id \
docker run -it \
    --user "$(id -u)":"$(id -g)"  \
    --network host \
    -v "${workdir}:/workdir" \
    -v "${workdir}/.venv-claude:/workdir/.venv" \
    -v "claude-home:/home/dev/.claude" \
    -v "$HOME/.dotfiles:/home/dev/.dotfiles:z" \
    -v "$HOME/.claude.json:/home/dev/.claude.json:z" \
    -v "$HOME/.netrc:/home/dev/.netrc:z" \
    -v "glab-config:/home/dev/.config/glab-cli" \
    claude-dev:latest
