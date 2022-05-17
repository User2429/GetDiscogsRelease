#pragma once

//	There are 4 markers per iteration: iteration, id_1, id_a, id_2.
//	Expect to be done in 32 iterations or less (but marker_rows can be resized if needed).
const int marker_count{ 4 };
const int marker_rows{ 32 };	
const int marker_size{ marker_count * marker_rows };

//	Maximum id size is 10 digits.
const long long max_id_length{ 10 };		

//	Set locale so that <fmt> functions write numbers with comma separator, e.g. 1,000.
const std::locale us("en_US.utf8");

//	Errors.
const std::string error_terminate{ "\nProcess terminated." };

//	Strings.
const std::string out_file_extension{ ".xml" };
const std::string out_file_prefix{ "discogs_ID_" };

//	String_views.
const std::string_view release_1{ "<release id=" };
const std::string_view release_2{ "</release>" };

//	Lengths.
const size_t len_release_1 = release_1.length();
const size_t len_release_2 = release_2.length(); 
