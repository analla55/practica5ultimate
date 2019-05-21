#!/bin/bash
#Autor: Óscar Anadón O.
#NIA: 760628
#practica 5 parte 3 volumenes logicos
if [ $# -ne 6 ]; then
	echo "Usage: $(basename $0) <ip> <grupoVolumen> <logicoVolumen> <size> <sistemaFicheros> <directorio>"
	exit 1
fi
ip=$1
shift
grupoVolumen=$1
logicoVolumen=$2
size=$3
sistemaFicheros=$4
directorio=$5

$(ssh -i /home/analla/.ssh/id_ed25519 -n as@"${ip}" sudo vgscan| grep " \"${grupoVolumen}\" " >/dev/null 2>&1)
if [ $? -ne 0 ]; then
	echo EL grupo volumen $grupoVolumen no existe
	exit 1
fi

$(ssh -i /home/analla/.ssh/id_ed25519 -n as@"${ip}" sudo lvscan| grep "${logicoVolumen}" >/dev/null 2>&1)
if [ $? -ne 0 ]; then
	# Creacion del volumen logico
	ssh -i /home/analla/.ssh/id_ed25519 -n  as@"${ip}" sudo lvcreate -L "${size}" -n "${logicoVolumen}" "${grupoVolumen}" >/dev/null 2>&1
	
	# Se le da formato al volumen logico
	ssh -i /home/analla/.ssh/id_ed25519 -n  as@"${ip}" sudo mkfs -t "${sistemaFicheros} /dev/${grupoVolumen}/${logicoVolumen}" >/dev/null 2>&1
	
	# Se monta el volumen loico
	ssh -i /home/analla/.ssh/id_ed25519 -n  as@"${ip}" sudo mount -t "${sistemaFicheros} /dev/${grupoVolumen}/${logicoVolumen} /${directorio}">/dev/null 2>&1
	
    # Configuramos para que lo monte al arrancar
    #importante uso de tee; Copy standard input to each FILE, and also to standard output.
	echo "/dev/${grupoVolumen}/${logicoVolumen}	${directorio}	${sistemaFicheros}		defaults	0	2" | ssh "as@$ip" sudo tee -a /etc/fstab >/dev/null 2>&1
	
	if [ $? -eq 0 ] ; then
		echo "Volumen logico creado y preparado para su montaje en el arranque"
	else
		echo "No se ha podido añadir el volumen lógico ${logicoVolumen} a /etc/fstab"
	fi
else 
	#Se extiende el tamaño del volumen logico
	ssh -i /home/analla/.ssh/id_ed25519 -n  as@"${ip}" sudo lvextend -L+${size} "/dev/${grupoVolumen}/${logicoVolumen}" > /dev/null 2>&1
	
	#Redefinimos el tamaño del sistema de ficheros montado
	ssh -i /home/analla/.ssh/id_ed25519 -n  as@"${ip}" sudo resize2fs "/dev/${grupoVolumen}/${logicoVolumen}" > /dev/null 2>&1
	if [ $? -eq 0 ] ; then
		echo "Sistema de ficheros /dev/${grupoVolumen}/${logicoVolumen} extendido correctamente"
	else
		echo "No se ha podido extender el sistema de ficheros /dev/${grupoVolumen}/${logicoVolumen}"
	fi
fi
