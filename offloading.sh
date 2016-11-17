#!/bin/bash
# Este programa realiza a contagem de palavras em um arquivo por meio
# da tecnica de offloading computacional.
# 
# Pre-requisitos: supomos que a sua chave publica ja estaja presente no host
# de destino. Caso contrario, use o comando abaixo:
# ssh-copy-id usuario@ip
#
# Mateus-n00b, Novembro 2016
#
# Versao 1.1
#
# Licenca GPL
# ---===============================================================---
# Comando util
# until grep  '0:00 wc -w ' foo 2>/dev/null; do ps -u > foo; done
# ------------------------------------------------

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <host1> <host2> <host3> ... <hostN>"
    exit
fi
# Recebo um arquivo do usuario
read -p ">> " ARQ

# Divido esse arquivo em arquivos menores obedecendo o número de substitutos
split -l $# $ARQ novo
cont=0
array=

# Preencho o array com os novos arquivos
for x in novo*
do
  array[$cont]=$x
  let cont++
done
# Aqui declaro as variaveis inicio e fim que serao utilizadas
# na divisao das tarefas.
fin=$[$(ls novo* | wc -l)/$#]
ini=0
sum=0

# Realizo um foreach para cada IP onde envio os arquivos a serem
# processados
for x in $*
do
    scp "${array[@]:$ini:$fin}" mateus@"$x":/home/mateus &> /dev/null
    # echo "${array[@]:$ini:$fin}"
    num=$(pdsh -w   mateus@"$x" "bash word_count.sh" | awk '{print $2}')
    sum=$[$num+$sum]
# Incremento as variaveis fin e ini para abranger todo o array
    ini=$fin
    fin=$[$fin+$fin]
done
echo -e "\033[33mO arquivo \"$ARQ\" tem $sum palavras. \033[0m"
rm novo*
