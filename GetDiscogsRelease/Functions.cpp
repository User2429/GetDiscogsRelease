#include "GetDiscogsRelease.h"
#include "Constants.h"
#include "Functions.h"

long long GetBlockSize(char* argv)
//	Bitshift operator is << (e.g. 1 << 18 = 2^18 = 262,144).
//	The external argument parser supplies a bitshift default argument of 18. 
//	Block size must exceed the length of the longest release in the input file (currently 68,436).
{
	return static_cast<long long>(1) << std::stoi(argv);
}

bool GetBoolean(char* argv)
//	Return boolean flag. 
{
	std::stringstream ss{ argv };
	bool b;
	ss >> std::boolalpha >> b;
	return b;
}

bool OpenInputFile(std::ifstream& file_in, const std::string path_in_full)
//	Open the input file at the end (ate) so that tellg() return the file size.
{
	try
	{
		file_in.open(path_in_full, std::ios::in | std::ios::binary | std::ios::ate);
		if (file_in.fail()) throw path_in_full;
		return true;
	}

	catch (std::string file_err)
	{
		std::cerr << "Failed to open input file " << file_err << error_terminate << std::endl;
		return false;
	}
}

bool InitializeInterval(std::ifstream& XML_input, const long long size, long long& pos_1, long long& pos_2, long long& pos_z,
	const int id, int& id_1, int& id_2)
	//	If there is no complete release id in the file then SearchForward fails and the program is terminated.
	//	If SearchForward finds a complete release id then SearchBackward will also and there will exist a first 
	//  and a last release id (although they need not be distinct) and corresponding position numbers.
	//	Use tellg() to get the file size and record it. The read block size may not exceed the file size.
{
	long long pos_ext_1{ 0 };
	long long pos_ext_2{ XML_input.tellg() };

	long long size_initial = size;
	if (size_initial > pos_ext_2) size_initial = pos_ext_2;

	if (!SearchForward(XML_input, size_initial, pos_ext_1, pos_1, id_1)) {
		std::cerr << "Input file contains no releases." << error_terminate << std::endl;
		return false;
	}

	SearchBackward(XML_input, size_initial, pos_ext_2, pos_2, id_2);
	pos_z = pos_ext_2;

	if (id < id_1 || id_2 < id) {
		std::cerr << "Release id " << id << " is outside the range [" << id_1 << ", " << id_2 << 
					 "] of release ids found in the input file." << error_terminate << std::endl;
		return false;
	}

	return true;
}

void SetIteration(int& i_count, int& id_a, long long& pos_a, bool& search_backward)
//	Set parameters for each search iteration.
{
	i_count++;
	id_a = 0;
	pos_a = 0;
	search_backward = false ;
}

bool SearchForward(std::ifstream& XML_input, const long long size, const long long pos_ext, long long& pos, int& id)
//	Return true if a complete release id is found after the current extended position pos_ext.
//	The complete release id must be of form <release="n" including the closing quote "; n is the id number.
//  Write the id value and position.
{
	std::vector<char>block(size + 1);

	if(!ReadBlock(XML_input, block, size, pos_ext)) return false;

	// Find the location of the start of the release id: <release=
	std::string_view block_sv(block.data());
	size_t loc_1 = block_sv.find(release_1, 0);
	if (loc_1 == std::string_view::npos) return false;

	// Find the location of the closing quote (") in the release id. 
	loc_1 += len_release_1 + 1;
	size_t loc_2 = block_sv.find("\"", loc_1);
	if (loc_2 == std::string_view::npos) return false;

	// Write the release id number (result is the from_chars return code) and its position.
	pos = pos_ext + loc_1;
	std::string_view id_sv = block_sv.substr(loc_1, loc_2 - loc_1);
	std::from_chars(id_sv.data(), id_sv.data() + id_sv.size(), id);

	return true;
}

bool SearchBackward(std::ifstream& XML_input, const long long size, const long long pos_ext, long long& pos, int& id)
//	Search backward from the extended postion to find the position and value for the release id nearest the end.
//	The complete release id must be of form <release="n" including the closing quote "; n is the id number.
//  If the first part of the release id, <release=, is found but the release id is not complete then search 
//	instead for the preceding release id. Write the release id value and position.
{
	long long pos_back = pos_ext - size;
	std::vector<char>block(size + 1);

	if(!ReadBlock(XML_input, block, size, pos_back)) return false;

	// Searching from the end, find the location of the start of the release id: <release=
	std::string_view block_sv(block.data());
	size_t loc_1 = block_sv.rfind(release_1, block_sv.size());
	if (loc_1 == std::string_view::npos) return false;

	// Find the location of the closing quote (") in the release id. 
	loc_1 += len_release_1 + 1;
	size_t loc_2 = block_sv.find("\"", loc_1);

	// If the closing quote (") is not found then search for the preceding release id.
	if (loc_2 == std::string_view::npos)
	{
		loc_1 = block_sv.rfind(release_1, loc_1 - len_release_1 - 1);
		if (loc_1 == std::string_view::npos) return false;
		loc_1 += len_release_1 + 1;

		loc_2 = block_sv.find("\"", loc_1);
		if (loc_2 == std::string_view::npos) return false;
	}

	// Write the release id number (result is the from_chars return code) and its position.
	pos = pos_back + loc_1;
	std::string_view id_sv = block_sv.substr(loc_1, loc_2 - loc_1);
	std::from_chars(id_sv.data(), id_sv.data() + id_sv.size(), id);

	return true;
}

bool ReadBlock(std::ifstream& XML_input, std::vector<char>& block, const long long size, const long long pos)
//	Read file to block.
{
	try
	{
		// Read a block of the given size beginning at position pos. 
		XML_input.seekg(pos);
		XML_input.read(block.data(), size);
		if (XML_input.fail()) throw "Input file read failure.";
		return true;
	}

	catch (std::string read_failure)
	{
		std::cerr << read_failure << error_terminate << std::endl;
		return false;
	}
}

bool ID_Endpoint(const int id, const int id_1, const int id_2, const long long pos_1, const long long pos_2,
	long long& pos_0)
	//	Return true if release id is a search interval endpoint. Assign position.
{
	if (id == id_1)
	{
		pos_0 = pos_1;
		return true;
	}

	if (id == id_2)
	{
		pos_0 = pos_2;
		return true;
	}

	return false;
}

bool LocateNextRecord(std::ifstream& XML_input, const bool binary_search, bool search_backward,
	const long long sizeB, double dA, const int id, const int id_1, const int id_2,
	const long long pos_1, const long long pos_2, int& id_a, long long& pos_a)
	//	Locate the next guess at the release id position in the search interval [id_1, id_2].
{
	// Next position is interpolated between positions 1 and 2. For binary search the default is dA = 0.5.
	if (!binary_search) dA = IntervalFraction(id, id_1, id_2);
	long long pos_e = pos_1 + (long long)((pos_2 - pos_1) * dA);

	// If pos_e is close to pos_2 search backwards. Cast int to long long to avoid C26541.
	if ((pos_2 - pos_e) < ((long long)len_release_1 + 1)) search_backward = true;

	// Search forward to find the next release after pos_e.
	// Decrease the read block size if necessary so that we do not read past pos_2.
	if (!search_backward)
	{
		long long size = (long long)sizeB;
		if ((pos_2 + max_id_length - pos_e) < size) size = pos_2 + max_id_length - pos_e;
		SearchForward(XML_input, size, pos_e, pos_a, id_a);
	}

	if (pos_a == pos_2) search_backward = true;

	// Search backward to find the release before pos_e.
	// Decrease the read block size if necessary so that we do not read backwards past pos_1.
	if (search_backward)
	{
		long long size = (long long)sizeB;
		if ((pos_e - pos_1) < size) size = pos_e - pos_1;
		if (!SearchBackward(XML_input, size, pos_e, pos_a, id_a))
		{
			std::cerr << "Release id " << id << " not found in the input file." << std::endl;
			return false;
		}
	}

	return true;
}

double IntervalFraction(const int i, const int i1, const int i2)
//	Return the length of the first part of an interval as a proportion: (i - i1) / (i2 - i1).
{
	double d = (double)i;
	double d1 = (double)i1;
	double d2 = (double)i2;
	return (d - d1) / (d2 - d1);
}

void UpdateInterval(const int id, int& id_1, int& id_2, long long& pos_1, long long& pos_2,
	const int id_a, const long long pos_a)
	//	Update the search interval positions and id values.
{
	if (id_a >= id)
	{
		pos_2 = pos_a;
		id_2 = id_a;
	}

	if (id_a < id)
	{
		pos_1 = pos_a;
		id_1 = id_a;
	}
}

void UpdateMarkers(std::vector<int>& markers, std::vector<size_t>& marker_widths, const int i_count,
	const int id_1, const int id_2, const int id_a, const bool detailed_output)
	//	Update search interval markers.
{
	if (!detailed_output) return;

	// Resize markers vector if necessary.
	if (i_count > marker_rows) markers.resize(markers.size() + marker_size, 0);

	// Record markers.
	int j = marker_count * (i_count - 1);
	markers[j] = i_count;
	markers[j + 1] = id_1;
	markers[j + 2] = id_a;
	markers[j + 3] = id_2;

	// For each marker record the greatest width so far.
	// fmt::formatted_size is based on the locale, so set this first.
	for (int i = 0; i < marker_count; i++)
	{
		size_t w = fmt::formatted_size("{:L}", markers[i + j]);
		if (marker_widths[i] < w) marker_widths[i] = w;
	}
}

void WriteMarkers(const std::vector<int> markers, std::vector<size_t> marker_widths, const int i_count,
	const bool detailed_output)
//	Write search interval markers.
{
	if (!detailed_output) return;

	std::vector<std::string> header{ "i", "id_1", "id_a", "id_2" };
	std::vector<std::string> fmt_h(marker_count);
	std::vector<std::string> fmt_r(marker_count);
	std::vector<std::string> row(marker_count);

	for (int i = 0; i < marker_count; i++)
	{
		size_t w = header[i].length();
		if (marker_widths[i] < w) marker_widths[i] = w;
		fmt_h[i] = "{:>" + std::to_string(marker_widths[i]) + "}";
		fmt_r[i] = "{:" + std::to_string(marker_widths[i]) + "L}";
		header[i] = fmt::format(fmt::runtime(fmt_h[i]), header[i]);
	}
	std::cout << header[0] << "  " << header[1] << "  " << header[2] << "  " << header[3] << "\n";

	for (int i = 0; i < i_count - 1; i++)
	{
		for (int j = 0; j < marker_count; j++)
		{
			row[j] = fmt::format(fmt::runtime(fmt_r[j]), markers[i * marker_count + j]);
		}
		std::cout << row[0] << "  " << row[1] << "  " << row[2] << "  " << row[3] << "\n";
	}
	std::cout << std::endl;
}

bool GetRelease(std::ifstream& XML_input, long long size, const long long pos_0, const long long pos_z, 
	std::string& release)
//	Get complete release record based on position.
{
	long long pos_start = pos_0 - len_release_1 - 1;
	if (size > pos_z - pos_start) size = pos_z - pos_start;
	std::vector<char>block(size + 1);
	XML_input.seekg(pos_start);

	if (!ReadBlock(XML_input, block, size, pos_start)) return false;;

	std::string_view block_sv(block.data());

	size_t loc_2 = block_sv.find(release_2, 0);
	if (loc_2 == std::string_view::npos)
	{
		std::cerr << "Closing tag " << release_2 << " not found in input file." << error_terminate << std::endl;
		return false;
	}
	loc_2 += len_release_2;

	release = (std::string)block_sv.substr(0, loc_2);
	return true;
}

bool OpenOutputFile(std::ofstream& file_out, const std::string& path_out, const int id, const std::string write_mode)
//	Open the output file. Construct the full file path from the folder path plus the release id.
{
	const std::string path_out_full = path_out + out_file_prefix + std::to_string(id) + out_file_extension;

	try
	{
		if (write_mode == "a") file_out.open(path_out_full, std::ios::out | std::ios::app);
		if (write_mode == "o") file_out.open(path_out_full, std::ios::out);
		if (file_out.fail()) throw path_out_full;
	}

	catch (std::string file_err)
	{
		std::cerr << "Failed to open output file " << file_err << error_terminate << std::endl;
		return false;
	}

	std::cout << "Discogs release record written to output file: " << path_out_full << '\n';
	return true;
}

void WriteRelease(std::ofstream& XML_release, std::string& release)
//	Write the release to the file.
{
	XML_release << release << std::endl;
	XML_release.close();
}