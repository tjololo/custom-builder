#!/bin/sh
value_of() {
	echo $(eval echo \$$1)
}
