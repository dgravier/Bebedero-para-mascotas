module proyecto(clk, nivel, led, servo);
input clk;		// señal de reloj
input nivel;		// señal sensor nivel
output reg led;		// salida al LED
output reg servo; 	// salida posicion servomotor
reg aux;		// Enciende una vez el servomotor se cierra, apaga cuando hay agua en el plato
reg [27:0] contador;	// Contador intervalos 10ms
reg [31:0] tiempoeval;	// Contador de tiempo de evaluación sensor
reg [31:0] tiemposervo;	// Contador de tiempo de encendido del servomotor
reg [1:0] estado;	// Estado del dispositivo
reg estadoservo;	// Registro estado de posicion servomotor
reg estadoagua;		// Registro estado de nivel de agua medido
// Inicia el ciclo de reloj
always@(posedge clk)begin
	// Actualizar contador
	contador=contador + 1;			// Contar cada ciclo reloj
	if(contador>1_000_000)begin	
		contador=0; 			// Reiniciar contador cada 10ms
	end	
	// Modulo sensor nivel, revisar sensor nivel
	estadoagua <= nivel; // estadoagua = 1, no hay agua
	// Estados
	// Estado 1: evaluar estado plato de agua
	if(estado == 1) begin
		if(estadoagua == 1) begin	// Si aun no hay agua en el plato...
			tiempoeval = tiempoeval +1;	// ...contar tiempoeval
		end else begin			// Si hay agua en el plato...
			tiempoeval = 0;			// ...Resetear tiempoeval
			estado = 0;			// ...Ir a estado 0 el proximo ciclo
		end
	end
	
	
	// Estado 2: llenando el plato
	if(estado == 2)begin
		estadoservo = 1;			// "Abrir" el servomotor
		tiemposervo = tiemposervo +1;		// contar tiempo servo
	end
	// Estado 0: defecto, plato lleno
	if (estado == 0) begin	
		if(estadoagua == 1) begin	// Cuando se vacie el plato...
			estado = 1;			// ...pasar a estado 1 en el proximo ciclo
		end else begin			// Si el plato esta lleno...
			led = 0;			//...apagar el led
			aux = 0;			//...apagar auxiliar
		end
	end
	// Procesos controlados por contadores
	// Si pasan x segundos sin llenarse el plato
	if(tiempoeval == 500_000_000)begin
		tiempoeval = 0;			// Reiniciar tiempoeval
		if(aux == 1)begin		// Si el servomotor acababa de cerrarse...
			led = 1;			//...prender led
			estado = 1;			//...ir a estado 1 en la proxima etapa
		end else begin			// Si el servomotor aún no se ha abierto
			estado = 2;			//...ir a estado 2 en la proxima etapa
		end
	end
	// Si pasan x segundos con el servomotor abierto
	if(tiemposervo == 500_000_000)begin
		estadoservo = 0;		// Cerrar el servomotor
		tiemposervo = 0;		// Reiniciar tiemposervo
		aux = 1;			// Inidcar que se acaba de cerrar el servomotor
		estado = 1;			// Pasar a estado 1
	end
	// Actualizar servomotor, modulo servomotor
	if(contador < (115_000+(115_000-(estadoservo*75_000))))begin
        servo=1;
    end else begin
        servo=0;
    end
end
endmodule 
