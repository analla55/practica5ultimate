#!/bin/bash
#Autor: Óscar Anadón O.
#NIA: 760628
#practica 5 parte 3 grupo volumen

if [ $# -lt 3 ]; then
	echo "Usage: $(basename $0) <ip> <volume_group> <disk_partition>"
	exit 89
fi
ip="$1"
vg="$2"
shift 2

#Comprobacion de la existencia de vgruo
#yo elijo que termine pero el guion no especifica, preguntar
vgOk=$(ssh -n as@"${ip}" sudo vgscan)
echo ${vgOk} | grep " \"${vg}\" " >/dev/null 2>&1
if [ $? -ne 0 ] ; then								
	echo "${vg} does not exist"
	exit 1
fi

for var in "$@"
do
#desmontamos de cualquier manera, en caso de que no este montado saltara aviso y vale
	ssh -i /home/analla/.ssh/id_ed25519 -n "as@${ip}" sudo umount ${var}"" >/dev/null 2>&1
	ssh -i /home/analla/.ssh/id_ed25519 -n "as@${ip}" sudo pvs | grep "${var}" >/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		echo "Ya existe el grupo físico ${var} y dentro de ${vg}"
	else
		ssh -i /home/analla/.ssh/id_ed25519 -n "as@${ip}" sudo pvcreate -y "${var}" #>/dev/null
	
		if [ $? -eq 0 ] ; then
			echo "Grupo físico ${var} creado correctamente"
		else
			echo "No se ha podido crear el grupo fisico ${var} - $"
			continue
		fi
		# Ya por fin extendemos volumen grooup
		ssh -i /home/analla/.ssh/id_ed25519 -n "as@${ip}" sudo vgextend -y "${vg}" "${var}" >/dev/null 2>&1
		# checkeamos su funcionamiento
		if [ $? -eq 0 ] ; then
			echo "Particion ${var} anadida al grupo 
			${vg} correctamente"
			
		else
			echo "No se ha podido anadir la particion ${var} al grupo ${vg} o particion ya creada"
		fi
	fi
done


