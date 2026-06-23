#!/bin/sh

# TODO: Make it POSIX-compliant

YELLOW='\033[33m'
PURPLE='\033[95m'
RESET='\033[0m'

HLCOLOR="${PURPLE}"
WRNCOLOR="${YELLOW}"

DEF_JOBS=5
test -z "$JOBS" && JOBS="${DEF_JOBS}"

__highlight(){
	echo -e "${HLCOLOR}""$@""${RESET}"
}

__warn(){
	echo -e "${WRNCOLOR}""$@""${RESET}"
}

__doas_make(){
	priv="$1"
	target="$2"
	shift 2
	flags="$@"

	__highlight "Running workload: " "${priv}" \
		"make -j${JOBS} ${flags} ${target}"
	if [ "${priv}" = "doas" ]; then
		doas make -j"${JOBS}" ${flags} "${target}"
	else
		make -j"${JOBS}" ${flags} "${target}"
	fi
}

regmake(){
	target="$1"
	shift 1
	flags="$@"

	__doas_make "" "${target}" ${flags}
}

rootmake(){
	target="$1"
	shift 1
	flags="$@"

	__doas_make "doas" "${target}" ${flags}
}

__do_kbuild(){
	#dest:
	dest="$1"
	shift 1
	flags="$@"

	regmake bzImage ${flags} && regmake modules ${flags} && rootmake \
		modules_install "INSTALL_MOD_PATH=${dest}" ${flags}
	#make -j"${JOBS}" ${flags} bzImage && make -j"${JOBS}" ${flags} \
	#	modules && doas make -j"${JOBS}" INSTALL_MOD_PATH="${dest}" \
	#	${flags} modules_install
}

__k_menuconf(){
	regmake menuconfig $@
}

ktags(){
	regmake gtags $@ && regmake tags $@ && regmake cscope $@ && \
		regmake compile_commands.json $@
}


kmenuconf(){
	__k_menuconf $@
}

kmenuconf-clang(){
	kmenuconf LLVM=1
}


kbuild(){
	dest="$1"
	shift 1
	flags="$@"
	__do_kbuild "${dest}" ${flags}
}

kbuild-clang(){
	dest="$1"
	shift 1
	flags="LLVM=1 $@"
	kbuild "${dest}" ${flags}
}

kbuild-vm(){
	vm="$1"
	shift 1
	flags="$@"

	dest="/opt/kdev/vms/${vm}"
	kbuild "${dest}" ${flags}
}

kbuild-clang-vm(){
	vm="$1"
	shift 1
	flags="LLVM=1 $@"

	kbuild-vm "${vm}" ${flags}
}
