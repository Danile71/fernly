.text

.global _start
_start:
disable_interrupts:
	mrs	r0, cpsr
	mov	r1, #0xc0
	orr	r0, r0, r1
	msr	cpsr_cxsf, r0

relocate_stack:
        ldr     r0, =0x70009ffc // stack_start
	mov     sp, r0

demo:
        mov     r0, #0x08
        bl      motor_pulse
        bl      reboot
error:                          // if we didn't reboot, leave motor on
        bl      motor_on
        b       error

.equ MOTOR_CTRL, 0xa07001b0
.equ MOTOR_CTRL_OFF, 0x0422
.equ MOTOR_CTRL_LOW, 0x8000
.equ MOTOR_CTRL_MED, 0x8010
.equ MOTOR_CTRL_HIGH, 0x8020

motor_on:
        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_HIGH
	str     r1, [r0]
        bx      lr

motor_off:
        ldr     r0, =MOTOR_CTRL
        ldr     r1, =MOTOR_CTRL_OFF
	str     r1, [r0]
        bx      lr

        // pulse motor r0 times
motor_pulse:
        push    {lr}
        mov     r4, r0
1:
        bl      motor_on
        bl      delay
        bl      motor_off
        bl      delay
        subs    r4, r4, #1
        bne     1b
        pop     {lr}
        bx      lr

        // trigger WDT reboot
reboot:
        ldr     r0, =0xa003001c
        ldr     r1, =0x1209
        str     r1, [r0]
        bx      lr              // shouldn't get here

delay:
        mov     r0, #0x400000
1:
        subs    r0, r0, #1
        bne     1b
        bx      lr
