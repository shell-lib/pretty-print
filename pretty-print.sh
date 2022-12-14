#!/usr/bin/env bash

# shellcheck source=/dev/null
source nonstdlib.sh
source_guard

function pprint() {
	FINAL_CHAR='\n'
	INDENT=''
	SHORTEN_PATHS=1 # enabled by default
	FD=1 # Write to stout by default
	THIS_PROGRAM_NAME="$0"

	# Create a color key/value map with an associative array
	# TODO: light/dark varients, bold, and underline
	declare -A COLOR_LOOKUP=(
		[red]='\033[31m'
		[yellow]='\033[33m'
		[green]='\033[32m'
		[blue]='\033[34m'
		[black]='\033[90m'
		[purple]='\033[35m'
		[cyan]='\033[36m'
		[default]='\033[m'
	)
	RESET_COLOR="${COLOR_LOOKUP[default]}"

	# Use the default when no choice given
	COLOR="${RESET_COLOR}"

	function list_possible_colors() {
		# '!' reads keys from the associative array
		echo "Avaliable colors:"
		for key in "${!COLOR_LOOKUP[@]}"; do
			value="${COLOR_LOOKUP[${key}]}"
			# If INDENT is unset or an empty string default to two spaces
			printf "${INDENT:=  }${value}%s${RESET_COLOR}\n" "${key}"
		done
	}

	function print_help_message() {
		echo "TODO: help message for pprint"
		list_possible_colors
	}

	while [[ "$#" -gt 0 ]]; do
		arg="$1"
		case "${arg}" in
		'--help' | '-h')
			print_help_message
			return 0
			;;

		'--list-colors')
			list_possible_colors
			return 0
			;;

		'--color' | '-c')
			# The next argument is the color choice
			if [[ "$#" -eq 1 ]]; then
				echo "${THIS_PROGRAM_NAME} error: color choice required after the '--color/-c' option"
				return 1
			fi
			shift
			# Check if the color choice is a valid key
			if [[ ${COLOR_LOOKUP["$1"]+_} ]]; then
				COLOR="${COLOR_LOOKUP[$1]}"
			else
				echo "${THIS_PROGRAM_NAME} error: invalid color choice '$1'"
				list_possible_colors
				return 1
			fi
			;;

		'--long-paths')
			SHORTEN_PATHS=0
			;;

		'--no-newline' | '-n')
			FINAL_CHAR=''
			;;

		'--indent' | '-i')
			# The next argument is the indentation
			if [[ "$#" -eq 1 ]]; then
				echo "${THIS_PROGRAM_NAME} error: indent character(s) required after the '--indent/-i' option"
			fi
			shift
			INDENT="$1"
			;;

		'--stdout')
			FD='2'
			;;

		'--')
			# Any args following '--' are considered part of the message to print
			shift
			break # Breaking here will stop us from hitting the '*' case with any leftover args. This way, we can print arguments that start with '-' without trying to parse as a registered option
			;;

		*)
			if [[ "${arg::1}" == '-' ]]; then
				echo "${THIS_PROGRAM_NAME} error: unknown option '${arg}'. If your string starts with '-', then run '${THIS_PROGRAM_NAME} -- <your string>'"
				return 2
			else
				# We can assume we've hit the first of our message to print (no more option args to parse)
				break # Break to stop from shifting off of the current arg
			fi
			;;
		esac
		shift # Move to next arg

	done

	if [[ "$#" -eq 0 ]]; then
		# No input to print given. Bail
		print_help_message
		return 2
	fi

	# Apply format and print the rest of the input args, $*
	message="$*"

	if [[ "${SHORTEN_PATHS}" -eq 1 ]]; then
  	# Replace working dir with '.' - this has to happen first incase the working dir is under $HOME
  	message="${message/${PWD}/.}"

		# Replace $HOME with an escaped '~'.
  	message="${message/${HOME}/\~}"
	fi

	# Note that we wrap with 'eval' to control the file redirection
	eval "printf '${COLOR}${INDENT}%s${RESET_COLOR}${FINAL_CHAR}' '${message}' >&${FD}"
	return 0
}

