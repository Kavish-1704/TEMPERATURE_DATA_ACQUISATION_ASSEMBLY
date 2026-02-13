################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/ADC.s \
../Src/DMA.s \
../Src/Itoa.s \
../Src/Tim2.s \
../Src/adctest.s \
../Src/lab_uart.s \
../Src/main.s 

C_SRCS += \
../Src/syscalls.c \
../Src/sysmem.c 

OBJS += \
./Src/ADC.o \
./Src/DMA.o \
./Src/Itoa.o \
./Src/Tim2.o \
./Src/adctest.o \
./Src/lab_uart.o \
./Src/main.o \
./Src/syscalls.o \
./Src/sysmem.o 

S_DEPS += \
./Src/ADC.d \
./Src/DMA.d \
./Src/Itoa.d \
./Src/Tim2.d \
./Src/adctest.d \
./Src/lab_uart.d \
./Src/main.d 

C_DEPS += \
./Src/syscalls.d \
./Src/sysmem.d 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.s Src/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -DDEBUG -c -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"
Src/%.o Src/%.su Src/%.cyclo: ../Src/%.c Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DSTM32 -DSTM32F4 -DSTM32F446RETx -c -I../Inc -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Src

clean-Src:
	-$(RM) ./Src/ADC.d ./Src/ADC.o ./Src/DMA.d ./Src/DMA.o ./Src/Itoa.d ./Src/Itoa.o ./Src/Tim2.d ./Src/Tim2.o ./Src/adctest.d ./Src/adctest.o ./Src/lab_uart.d ./Src/lab_uart.o ./Src/main.d ./Src/main.o ./Src/syscalls.cyclo ./Src/syscalls.d ./Src/syscalls.o ./Src/syscalls.su ./Src/sysmem.cyclo ./Src/sysmem.d ./Src/sysmem.o ./Src/sysmem.su

.PHONY: clean-Src

