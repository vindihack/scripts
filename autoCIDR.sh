#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Definición de la función Ctrl+C y binding de esta

function ctrl_c(){
	echo -e "\n\n ${redColour}[!] ¡El proceso ha sido interrumpido!${endColour}\n"
	exit 1
}

trap ctrl_c INT

##Funciones del programa

#Función panel de ayuda
function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Utilidad para extraer información de una dirección IP en formato CIDR.\n\tUsage: ${endColour}${yellowColour}./autoCIDR.sh -i [direccionIP/CIDR]\n\t${grayColour}Ejemplo: ${endColour}${yellowColour}./autoCIDR.sh -i 192.168.1.1/24${endColour}"
}

#Error

#Preformatea la dirección ip (X.X.X.X/X) para convertir cada bloque y CIDR a binario

function format(){
	src_block1=$(echo "$sourceIP" | cut -d "." -f 1)
	src_block2=$(echo "$sourceIP" | cut -d "." -f 2)
	src_block3=$(echo "$sourceIP" | cut -d "." -f 3)
	src_block4=$(echo "$sourceIP" | cut -d "." -f 4 | cut -d "/" -f 1)
	src_CIDR=$(echo "$sourceIP" | cut -d "." -f 4 | cut -d "/" -f 2)
}

#Función convertir IP de decimal a binario
function convert2Binary(){

bin_block1=$(echo -e "obase=2;$src_block1" | bc)
bin_block2=$(echo -e "obase=2;$src_block2" | bc)
bin_block3=$(echo -e "obase=2;$src_block3" | bc)
bin_block4=$(echo -e "obase=2;$src_block4" | bc)

bin1=$(padding $bin_block1)
bin2=$(padding $bin_block2)
bin3=$(padding $bin_block3)
bin4=$(padding $bin_block4)

	#Convertir CIDR a binario
	if [ "$src_CIDR" -gt 0 ] && [ "$src_CIDR" -le 32 ]; then
		ones=$(printf "%0.s1" $(seq 1 "$src_CIDR"))
		zeros=$(printf "%0.s0" $(seq 1 $((32 - n))))
		result="$ones$zeros"
		CIDR1=$(echo "$result" | sed -r 's/.{8}/& /g' | cut -d' ' -f1)
		CIDR2=$(echo "$result" | sed -r 's/.{8}/& /g' | cut -d' ' -f2)
		CIDR3=$(echo "$result" | sed -r 's/.{8}/& /g' | cut -d' ' -f3)
		CIDR4=$(echo "$result" | sed -r 's/.{8}/& /g' | cut -d' ' -f4)
		fullCIDR=$(echo "$CIDR1"."$CIDR2"."$CIDR3"."$CIDR4")
    fi

binaryIP=$(echo "$bin1"."$bin2"."$bin3"."$bin4")
binaryCIDR=$(echo "$fullCIDR")

}

#Función para obtener networkID binario
function generate_binaryNetworkID(){

cadena1="$bin1"
cadena2="$CIDR1"
cadena3="$bin2"
cadena4="$CIDR2"
cadena5="$bin3"
cadena6="$CIDR3"
cadena7="$bin4"
cadena8="$CIDR4"
nueva_cadena1=""
nueva_cadena2=""
nueva_cadena3=""
nueva_cadena4=""

	for ((i = 0; i < 8; i++)); do

    char_bin1="${cadena1:i:1}"
    char_CIDR1="${cadena2:i:1}"

	if [ "$char_bin1" == "1" ] && [ "$char_CIDR1" == "1" ]; then
		nueva_cadena1="${nueva_cadena1}1"
	else
		nueva_cadena1="${nueva_cadena1}0"
	fi
	done

	for ((i = 0; i < 8; i++)); do

	char_bin2="${cadena3:i:1}"
	char_CIDR2="${cadena4:i:1}"

	if [ "$char_bin2" == "1" ] && [ "$char_CIDR2" == "1" ]; then
		nueva_cadena2="${nueva_cadena2}1"
	else
		nueva_cadena2="${nueva_cadena2}0"
	fi
	done

	for ((i = 0; i < 8; i++)); do

	char_bin3="${cadena5:i:1}"
	char_CIDR3="${cadena6:i:1}"

	if [ "$char_bin3" == "1" ] && [ "$char_CIDR3" == "1" ]; then
    	nueva_cadena3="${nueva_cadena3}1"
	else
		nueva_cadena3="${nueva_cadena3}0"
	fi
	done

	for ((i = 0; i < 8; i++)); do

	char_bin4="${cadena7:i:1}"
	char_CIDR4="${cadena8:i:1}"

	if [ "$char_bin4" == "1" ] && [ "$char_CIDR4" == "1" ]; then
		nueva_cadena4="${nueva_cadena4}1"
	else
		nueva_cadena4="${nueva_cadena4}0"
	fi
	done

binaryNetworkID=$(echo "$nueva_cadena1"."$nueva_cadena2"."$nueva_cadena3"."$nueva_cadena4")

}

#Función para obtener Broadcast IP en binario
function generateBroadcastIP() {

resto_broadcastIP=$((32 - $src_CIDR))
binaryBroadcastIP_incomplete=$(echo "$nueva_cadena1""$nueva_cadena2""$nueva_cadena3""$nueva_cadena4" | cut -c -$((32 - $resto_broadcastIP)))
binaryBroadcastIP_complement=$(printf '1%.0s' $(seq 1 $resto_broadcastIP))
binaryBroadcastIP_almost="$binaryBroadcastIP_incomplete$binaryBroadcastIP_complement"
binaryBroadcastIP_definitive=$(echo "$binaryBroadcastIP_almost" | sed -E 's/([01]{8})/\1./g;s/\.$//')

}

#Función para padding de binarios
function padding(){

padding_block="$1"
target_length=8
current_length=$(echo -n "$padding_block" | wc -c)

	if [ $current_length -lt $target_length ]; then
		zeros_to_add=$((target_length - current_length))
		padding_zeros=$(printf "%0${zeros_to_add}d" 0)
		padded_block="${padding_zeros}${padding_block}"
		echo "$padded_block"
	else
		echo "$padding_block"
	fi

}

#Función convertir de binario a decimal (EN CONSTRUCCION)
function convert2Decimal(){

#IP
decimalIP=$(echo "$sourceIP" | cut -d "/" -f 1)

#Máscara de red
decimalMask_block1=$(echo -e "obase=10;ibase=2;$CIDR1" | bc)
decimalMask_block2=$(echo -e "obase=10;ibase=2;$CIDR2" | bc)
decimalMask_block3=$(echo -e "obase=10;ibase=2;$CIDR3" | bc)
decimalMask_block4=$(echo -e "obase=10;ibase=2;$CIDR4" | bc)

decimalMask=$(echo "$decimalMask_block1"."$decimalMask_block2"."$decimalMask_block3"."$decimalMask_block4")

#Network ID
decimalNetworkID_block1=$(echo -e "obase=10;ibase=2;$nueva_cadena1" | bc)
decimalNetworkID_block2=$(echo -e "obase=10;ibase=2;$nueva_cadena2" | bc)
decimalNetworkID_block3=$(echo -e "obase=10;ibase=2;$nueva_cadena3" | bc)
decimalNetworkID_block4=$(echo -e "obase=10;ibase=2;$nueva_cadena4" | bc)

decimalNetworkID=$(echo "$decimalNetworkID_block1"."$decimalNetworkID_block2"."$decimalNetworkID_block3"."$decimalNetworkID_block4")

#Broadcast IP
semiBroadcast_block1=$(echo "$binaryBroadcastIP_incomplete$binaryBroadcastIP_complement" | cut -c -8)
decimalBroadcast_block1=$(echo -e "obase=10;ibase=2;$semiBroadcast_block1" | bc)
semiBroadcast_block2=$(echo "$binaryBroadcastIP_incomplete$binaryBroadcastIP_complement" | cut -c 9-16)
decimalBroadcast_block2=$(echo -e "obase=10;ibase=2;$semiBroadcast_block2" | bc)
semiBroadcast_block3=$(echo "$binaryBroadcastIP_incomplete$binaryBroadcastIP_complement" | cut -c 17-24)
decimalBroadcast_block3=$(echo -e "obase=10;ibase=2;$semiBroadcast_block3" | bc)
semiBroadcast_block4=$(echo "$binaryBroadcastIP_incomplete$binaryBroadcastIP_complement" | cut -c 25-)
decimalBroadcast_block4=$(echo -e "obase=10;ibase=2;$semiBroadcast_block4" | bc)

decimalBroadcastIP=$(echo -e "$decimalBroadcast_block1"."$decimalBroadcast_block2"."$decimalBroadcast_block3"."$decimalBroadcast_block4")

#decimalFirstHost=$(echo "$sourceIP" | cut -d "." -f 4 | cut -d "/" -f 2)
#decimalLastHost=$(echo "$sourceIP" | cut -d "." -f 4 | cut -d "/" -f 2)

}

#Indicadores
declare -i parameter_counter=0

	while getopts "i:h" arg; do
		case $arg in
		i) sourceIP="$OPTARG"; let parameter_counter+=1;;
		h) helpPanel;;
		esac
	done

	if [ "$parameter_counter" -eq 1 ]; then
		tput civis
    	format
    	convert2Binary
		generate_binaryNetworkID
		generateBroadcastIP
		convert2Decimal
		echo -e "\n${yellowColour}[+]${endColour}La dirección IP proporcionada es ->"
    	echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Información binaria:${endColour}"
    	echo -e "${grayColour}Dirección IP:${endColour}${yellowColour}	$binaryIP ${endColour}"
    	echo -e "${grayColour}Máscara de red:${endColour}${yellowColour}	$binaryCIDR ${endColour}"   
    	echo -e "${grayColour}Network ID:${endColour}${yellowColour}	$binaryNetworkID ${endColour}"
    	echo -e "${grayColour}Broadcast IP:${endColour}${yellowColour}	$binaryBroadcastIP_definitive ${endColour}"
    	echo -e "\n${yellowColour}[+]${endColour} ${blueColour}Información decimal:${endColour}"
    	echo -e "${grayColour}Dirección IP:${endColour}${yellowColour}	$decimalIP ${endColour}"
    	echo -e "${grayColour}Máscara de red:${endColour}${yellowColour}	$decimalMask ${endColour}"   
    	echo -e "${grayColour}Network ID:${endColour}${yellowColour}	$decimalNetworkID ${endColour}"
    	echo -e "${grayColour}Broadcast IP:${endColour}${yellowColour}	$decimalBroadcastIP ${endColour}"
		tput cnorm
	fi

