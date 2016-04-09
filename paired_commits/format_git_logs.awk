# Formats the output of git log --name-status so that files connected
# in commits are represented

# Given an array of file names in a commit, return an array
# of file a -> file b
# e.g.:
# file_array[1] = 'file1'
# file_array[2] = 'file2'
# file_array[3] = 'file3'
# get_file_links(file_array)
# ->
# ['file1 file2', 'file1 file3', 'file2 file1', 'file2 file3']
function get_file_links(file_array, results_collector) {
  result_index = 1

  for (linking_file in file_array) {
    for (linked_file in file_array) {
      if (file_array[linking_file] == file_array[linked_file]) {
        continue
      }

      results_collector[result_index] = file_array[linked_file] " " file_array[linking_file]
      result_index++
    }
  }
}

# has the side effect of modifying the global counts of linkages
function update_linkage_counts(linkages) {
  for(linkage in linkages) {
    link_counts[linkages[linkage]] += 1
  }
}


BEGIN {
  files_in_commit = 0
  commit_files[0] = ""
  total_commits = 0
  OFS=","
}

# marks the beginning of a new commit. This is a point to
# collect the pairs of all commit files and store them in
# file_link_results
/^commit/ {
  total_commits += 1

  delete results_collector
  results_collector[1] = ""
  get_file_links(commit_files, results_collector)
  update_linkage_counts(results_collector)

  files_in_commit = 0
  delete commit_files
}

/^[AMD][ \t]+/ {
  files_in_commit += 1
  commit_files[files_in_commit] = $2
}

END {
  # handle lingering data
  delete results_collector
  results_collector[1] = ""
  get_file_links(commit_files, results_collector)
  update_linkage_counts(results_collector)

  # for each linkage, print total number of commits where they were linked and percentage
  for( linkage in link_counts) {
    formatted_linkage = linkage
    gsub(" ", ",", formatted_linkage)
    print formatted_linkage, link_counts[linkage], 100 * (link_counts[linkage]/total_commits)
  }
}
