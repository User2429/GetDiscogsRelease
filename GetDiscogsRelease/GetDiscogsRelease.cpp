//	GetDiscogsRelease.
//	Given a discogs release id write the corresponding release record to a file.
//	May 2022.

#include "GetDiscogsRelease.h"
#include "Constants.h"
#include "Functions.h"

//	Variables.
bool search_backward{ false };
double dA{ 0.5 };
int i_count{ 0 };
int id_a{ 0 };
int id_1{ 1 };
int id_2{ 1 };
long long pos_a{ 0 };
long long pos_0{ 0 };
long long pos_1{ 0 };
long long pos_2{ 0 };
long long pos_z{ 0 };

std::string release;
std::vector<int> markers(marker_size, 0);
std::vector<size_t> marker_widths(marker_count, 0);

//  File streams.
std::ifstream XML_input;
std::ofstream XML_release;

int main(int, char* argv[])
{
	std::locale::global(us);

	const std::string XML_PathIn_Full{ argv[1] };
	const std::string XML_PathOut{ argv[2] };
	const int id{ std::stoi(argv[3]) };
	const std::string write_mode{ argv[4] };
	const long long sizeB = GetBlockSize(argv[5]);
	const bool binary_search = GetBoolean(argv[6]);
	const bool detailed_output = GetBoolean(argv[7]);

	if (!OpenInputFile(XML_input, XML_PathIn_Full)) return 10;
	if (!InitializeInterval(XML_input, sizeB, pos_1, pos_2, pos_z, id, id_1, id_2)) return 20;

	//	For the case in which the id is the first or last in the file:
	//	1. Run UpdateMarkers. Otherwise control exits the loop before it is run even once.
	//	2. Increment i_count to 2. Otherwise WriteMarkers produces no output.
	UpdateMarkers(markers, marker_widths, 1, id_1, id_2, id, detailed_output);

	// Search for release id.
	while (true)
	{
		SetIteration(i_count, id_a, pos_a, search_backward);
		if (ID_Endpoint(id, id_1, id_2, pos_1, pos_2, pos_0)) {
			if (i_count == 1) { i_count++; }
			break;}
		if (!LocateNextRecord(XML_input, binary_search, search_backward, sizeB, dA, id, id_1, id_2,
			pos_1, pos_2, id_a, pos_a)) return 30;
		UpdateMarkers(markers, marker_widths, i_count, id_1, id_2, id_a, detailed_output);
		UpdateInterval(id, id_1, id_2, pos_1, pos_2, id_a, pos_a);
	}

	// Write release.
	WriteMarkers(markers, marker_widths, i_count, detailed_output);
	if(!GetRelease(XML_input, sizeB, pos_0, pos_z, release)) return 40;
	if (!OpenOutputFile(XML_release, XML_PathOut, id, write_mode)) return 50;
	WriteRelease(XML_release, release);

	return 0;
}
