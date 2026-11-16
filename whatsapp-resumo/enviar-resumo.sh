#!/bin/bash
# Pega o último "📬 Assistente" no app Mail, recorta o bloco ===WHATSAPP=== e manda pelo Hermes.
# Uso: enviar-resumo.sh            -> envia (uma vez por e-mail)
#      enviar-resumo.sh --teste    -> só mostra o que mandaria
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
DESTINO="${DESTINO:-whatsapp}"          # ex.: whatsapp  ou  whatsapp:5548999999999
HORAS="${HORAS:-12}"                    # só considera e-mails das últimas N horas
DIR="$HOME/.resumo-whatsapp"; mkdir -p "$DIR"
LOG="$DIR/log.txt"; ULTIMO="$DIR/ultimo-id"

saida=$(osascript <<OSA 2>>"$LOG"
tell application "Mail"
  set limite to (current date) - ($HORAS * hours)
  set achados to (messages of inbox whose subject contains "Assistente —" and subject does not start with "Re:" and date received > limite)
  if (count of achados) = 0 then return ""
  set m to item 1 of achados
  repeat with x in achados
    if date received of x > date received of m then set m to x
  end repeat
  return (message id of m) & linefeed & "@@CORPO@@" & linefeed & (content of m)
end tell
OSA
)

[ -z "$saida" ] && { echo "$(date '+%F %T') nada novo" >>"$LOG"; exit 0; }
id=$(printf '%s\n' "$saida" | head -1)
texto=$(printf '%s\n' "$saida" | awk '/===WHATSAPP===/{f=1;next} /===FIM WHATSAPP===/{f=0} f')
texto=$(printf '%s\n' "$texto" | sed -e 's/[[:space:]]*$//' | sed -e '/./,$!d')

if [ -z "$texto" ]; then echo "$(date '+%F %T') e-mail sem bloco WHATSAPP ($id)" >>"$LOG"; exit 0; fi
if [ "$1" = "--teste" ]; then printf '%s\n' "--- mandaria para $DESTINO ---" "$texto"; exit 0; fi
[ -f "$ULTIMO" ] && [ "$(cat "$ULTIMO")" = "$id" ] && { echo "$(date '+%F %T') já enviado" >>"$LOG"; exit 0; }

if printf '%s\n' "$texto" | hermes send --to "$DESTINO" >>"$LOG" 2>&1; then
  echo "$id" >"$ULTIMO"; echo "$(date '+%F %T') enviado ($id)" >>"$LOG"
else
  echo "$(date '+%F %T') ERRO no hermes send" >>"$LOG"; exit 1
fi
