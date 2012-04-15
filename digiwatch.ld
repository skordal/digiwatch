/* DigiWatch Linker Script
 * (c) Kristian Klomsten Skordal 2012 <kristian.skordal@gmail.com>
 * Report bugs and issues on <http://github.com/skordal/digiwatch/issues>
 */

SECTIONS
{
	.text :
	{
		interrupts.o
		*(.text)
	}

	.data 0x800000 :
	{
		*(.data)
		*(.bss)
	}
}

