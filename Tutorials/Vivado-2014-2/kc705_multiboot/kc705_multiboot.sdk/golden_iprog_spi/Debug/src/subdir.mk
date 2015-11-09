################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/golden.c \
../src/xgpio_tapp_example.c \
../src/xhwicap_low_level_example.c 

LD_SRCS += \
../src/lscript.ld 

OBJS += \
./src/golden.o \
./src/xgpio_tapp_example.o \
./src/xhwicap_low_level_example.o 

C_DEPS += \
./src/golden.d \
./src/xgpio_tapp_example.d \
./src/xhwicap_low_level_example.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MicroBlaze gcc compiler'
	mb-gcc -Wall -O0 -g3 -c -fmessage-length=0 -I../../standalone_bsp_0/microblaze_0/include -mlittle-endian -mxl-barrel-shift -mcpu=v9.3 -mxl-soft-mul -Wl,--no-relax -ffunction-sections -fdata-sections -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


