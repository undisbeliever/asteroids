
ROM_NAME      = Asteroids
CONFIG        = LOROM_1MBit_copyright
API_MODULES   = reset-snes sfc-header block screen text text8x8 math random metasprite
API_DIR       = snesdev-common
SOURCE_DIR    = src
TABLES_DIR    = tables
RESOURCES_DIR = resources

include $(API_DIR)/Makefile.in

