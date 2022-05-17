#pragma once

//	Advance declarations.
bool SearchBackward(std::ifstream&, const long long, const long long, long long&, int&);
bool SearchForward(std::ifstream&, const long long, const long long, long long&, int&);

std::string GetString(const std::string_view&, const size_t&, const size_t&);

//	Functions.
bool GetBoolean(char*);
bool GetRelease(std::ifstream&, long long, const long long, const long long, std::string&);
bool ID_Endpoint(const int, const int, const int, const long long, const long long, long long&);
bool InitializeInterval(std::ifstream&, const long long, long long&, long long&, long long&, const int, int&, int&);
bool LocateNextRecord(std::ifstream&, const bool, bool, const long long, double, const int, const int, const int,
	const long long, const long long, int&, long long&);
bool OpenInputFile(std::ifstream&, const std::string);
bool OpenOutputFile(std::ofstream&, const std::string&, const int, const std::string);
bool ReadBlock(std::ifstream&, std::vector<char>&, const  long long, const long long);

double IntervalFraction(const int, const int, const int);
long long GetBlockSize(char*);

void SetIteration(int&, int&, long long&, bool&);
void UpdateInterval(const int, int&, int&, long long&, long long&, const int, const long long);
void UpdateMarkers(std::vector<int>&, std::vector<size_t>&, const int, const int, const int, const int, const bool);
void WriteMarkers(const std::vector<int>, const std::vector<size_t>, const int, const bool);
void WriteRelease(std::ofstream& XML_release, std::string& release);
