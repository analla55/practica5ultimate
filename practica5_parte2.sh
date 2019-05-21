#!/bin/bash
#Autor: Óscar Anadón O.
#NIA: 760628
#practica 5 parte 2
if [ $# != 1 ] ; then
		echo "Usage: $(basename $0) <IP>"
		exit 1
fi

echo Conectando a la IP "$1" ...
ssh -i /home/analla/.ssh/id_ed25519 as@"$1"  -n  >/dev/null 2>&1
if [ $? = 0 ] ; then 
	echo Conectado a la IP "$1"
	echo "Discos duros y tamanos (en bloques):"
	ssh -i /home/analla/.ssh/id_ed25519 -n as@"$1" sudo sfdisk -s
	echo "Particiones y tamanos (en bloques):"
	ssh -i /home/analla/.ssh/id_ed25519 -n as@"$1" sudo sfdisk -l
	echo -e "Particion/vol. logico, tipo sistema ficheros, direccion, tamano y espacio libre:\n"
	ssh -i /home/analla/.ssh/id_ed25519 -n as@"$1" df -hT
else 
	echo "Error: IP $1 invalida o imposible de conectar"
fi
