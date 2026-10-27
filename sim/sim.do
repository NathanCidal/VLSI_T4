if {! [ file exists work ] } { 
        echo "criando biblioteca WORK..."
        vlib work
        echo " "
} else {
        echo "apagando biblioteca WORK..."
        vdel -all
        echo "recriando biblioteca WORK..."
        vlib work
        echo " "
}

## comando de compilação. s
vlog    ../rtl/watchdog.sv
vlog    ../rtl/ps2_decoder.sv
vlog    ../rtl/ps2_driver.sv
vlog    ../sim/ps2_driver_tb.sv

## comando de simulação  
vsim -voptargs=+acc -wlfdeleteonquit work.ps2_driver_tb
        
set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1 

## adição dos sinais na forma de onda.  
restart -f
add wave sim:/*

## execução da simulação.    
run 900us
