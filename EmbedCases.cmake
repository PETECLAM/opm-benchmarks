# -*- mode: cmake; tab-width: 2; indent-tabs-mode: t; truncate-lines: t; compile-command: "cmake -Wdev" -*-
# vim: set filetype=cmake autoindent tabstop=2 shiftwidth=2 noexpandtab softtabstop=2 nowrap:

macro (pack_file case_dir case_name suffix in_ext out_ext)
  # put the output in the same relative path in the output; we then
  # get no change if we build in-source
  set (rel_file "${case_dir}/${case_name}${suffix}")
  set (input_file "${PROJECT_SOURCE_DIR}/${rel_file}${in_ext}")
  set (output_file "${PROJECT_BINARY_DIR}/${rel_file}${out_ext}")

  # make sure that the output directory exists
  get_filename_component (output_dir "${output_file}" PATH)
  file (MAKE_DIRECTORY "${output_dir}")

  # run the shell script to encode the file
  add_custom_command (
	OUTPUT "${output_file}"
	COMMAND "${PROJECT_SOURCE_DIR}/benchmarks/input/create_hex_data_file.sh"
	ARGS "${input_file}" "${output_file}"
	DEPENDS "${input_file}"
	COMMENT "Creating packed binary of ${rel_file}"
	)

  # cannot add files to targets other than in add_custom_target,
  # and that command can only run once, so we must return a list
  # of dependencies that is added
  list (APPEND ${case_name}_DEPENDS "${output_file}")
endmacro (pack_file)

# each case consists of a .grdecl file and a .data file
macro (pack_case test_exe case_name)
  pack_file ("benchmarks/input" "${case_name}" "_grid" ".grdecl" ".dat")
  pack_file ("benchmarks/input" "${case_name}" "_upscaled_relperm" ".out" ".dat")

  # we cannot add files directly (sic) but must wrap in a target
  add_custom_target (${case_name} ALL DEPENDS ${${case_name}_DEPENDS})
  add_dependencies ("${test_exe}" "${case_name}")
endmacro (pack_case)

# rel.perm curve is packed separately because it is common for all cases
macro (pack_stone test_exe)
	pack_file ("benchmarks/input" "stonefile" "_benchmark" ".txt" ".dat")
	add_custom_target (stonefile ALL DEPENDS ${stonefile_DEPENDS})
	add_dependencies ("${test_exe}" "stonefile")
endmacro (pack_stone)

# pack these cases which are alternatives in the code
pack_stone (upscale_relperm_benchmark)
pack_case (upscale_relperm_benchmark benchmark_tiny)
pack_case (upscale_relperm_benchmark benchmark20)
pack_case (upscale_relperm_benchmark benchmark75)
