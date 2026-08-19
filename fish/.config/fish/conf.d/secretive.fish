# Secretive keeps the commit-signing key in the Secure Enclave and hands it out over
# its own agent socket, which git reaches through SSH_AUTH_SOCK. The path is derived
# from the app's bundle ID, so it is the same on every Mac.

set -l secretive_socket $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

if test -S $secretive_socket
    set -gx SSH_AUTH_SOCK $secretive_socket
end
