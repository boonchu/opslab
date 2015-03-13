/*
 *  hello.c
 */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int hello_world_data __initdata = 1;

static int __init new(void)
{
	printk(KERN_INFO "Hello World %d\n", hello_world_data);
	return 0;
}

static void __exit destroy(void)
{
	printk(KERN_INFO "Goodbye world \n");
}

module_init(new);
module_exit(destroy);
