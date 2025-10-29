if status is-interactive
	alias ls="eza -a --icons --group-directories-first -w 80"
	alias clima="clear && curl http://wttr.in/Juazeiro"
	alias jusfy="tilix -s default.json && exit"
	zoxide init fish --cmd cd | source   
 # Commands to run in interactive sessions can go here
end



string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
