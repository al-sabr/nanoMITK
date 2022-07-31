/*============================================================================

The Medical Imaging Interaction Toolkit (MITK)

Copyright (c) German Cancer Research Center (DKFZ)
All rights reserved.

Use of this source code is governed by a 3-clause BSD license that can be
found in the LICENSE file.

============================================================================*/

#include <mitkStandardFileLocations.h>

#include <itkMacro.h>
#include <itkObject.h>
#include <kwsys/SystemTools.hxx>
#include <mitkConfig.h>
#include <mitkUtf8Util.h>

#include <algorithm>

mitk::StandardFileLocations::StandardFileLocations()
{
}

mitk::StandardFileLocations::~StandardFileLocations()
{
}

mitk::StandardFileLocations *mitk::StandardFileLocations::GetInstance()
{
  static StandardFileLocations::Pointer m_Instance = nullptr;

  if (m_Instance.IsNull())
    m_Instance = StandardFileLocations::New();
  return m_Instance;
}

void mitk::StandardFileLocations::AddDirectoryForSearch(const char *dir, bool insertInFrontOfSearchList)
{
  // Do nothing if directory is already included into search list (TODO more clever: search only once!)
  FileSearchVectorType::iterator iter;
  if (m_SearchDirectories.size() > 0)
  {
    iter = std::find(m_SearchDirectories.begin(), m_SearchDirectories.end(), std::string(dir));
    if (iter != m_SearchDirectories.end())
      return;
  }
  // insert dir into queue
  if (insertInFrontOfSearchList)
  {
    auto it = m_SearchDirectories.begin();
    m_SearchDirectories.insert(it, std::string(dir));
  }
  else
    m_SearchDirectories.push_back(std::string(dir));
}

void mitk::StandardFileLocations::RemoveDirectoryForSearch(const char *dir)
{
  FileSearchVectorType::iterator it;
  // background layers
  if (m_SearchDirectories.size() > 0)
  {
    it = std::find(m_SearchDirectories.begin(), m_SearchDirectories.end(), std::string(dir));
    if (it != m_SearchDirectories.end())
    {
      m_SearchDirectories.erase(it);
      return;
    }
  }
}

std::string mitk::StandardFileLocations::SearchDirectoriesForFile(const char *filename)
{
  FileSearchVectorType::iterator it;

  for (it = m_SearchDirectories.begin(); it != m_SearchDirectories.end(); ++it)
  {
    std::string currDir = (*it);

    // Perhaps append "/" before appending filename
    if (currDir.find_last_of("\\") + 1 != currDir.size() || currDir.find_last_of("/") + 1 != currDir.size())
      currDir += "/";

    // Append filename
    currDir += filename;

    // Perhaps remove "/" after filename
    if (currDir.find_last_of("\\") + 1 == currDir.size() || currDir.find_last_of("/") + 1 == currDir.size())
      currDir.erase(currDir.size() - 1, currDir.size());

    // convert to OS dependent path schema
    currDir = Utf8Util::Utf8ToLocal8Bit(kwsys::SystemTools::ConvertToOutputPath(Utf8Util::Local8BitToUtf8(currDir).c_str()));

    // On windows systems, the ConvertToOutputPath method quotes pathes that contain empty spaces.
    // These quotes are not expected by the FileExists method and therefore removed, if existing.
    if (currDir.find_last_of("\"") + 1 == currDir.size())
      currDir.erase(currDir.size() - 1, currDir.size());
    if (currDir.find_last_of("\"") == 0)
      currDir.erase(0, 1);

    // Return first found path
    if (kwsys::SystemTools::FileExists(Utf8Util::Local8BitToUtf8(currDir).c_str()))
      return currDir;
  }
  return std::string("");
}

std::string mitk::StandardFileLocations::FindFile(const char *filename, const char *pathInSourceDir)
{
  std::string directoryPath;

  // 1. look for MITKCONF environment variable
  const char *mitkConf = kwsys::SystemTools::GetEnv("MITKCONF");
  if (mitkConf != nullptr)
    AddDirectoryForSearch(mitkConf, false);

// 2. use .mitk-subdirectory in home directory of the user
#if defined(_WIN32) && !defined(__CYGWIN__)
  const char *homeDrive = kwsys::SystemTools::GetEnv("HOMEDRIVE");
  const char *homePath = kwsys::SystemTools::GetEnv("HOMEPATH");

  if ((homeDrive != nullptr) || (homePath != nullptr))
  {
    directoryPath = homeDrive;
    directoryPath += homePath;
    directoryPath += "/.mitk/";
    AddDirectoryForSearch(directoryPath.c_str(), false);
  }

#else
  const char *homeDirectory = kwsys::SystemTools::GetEnv("HOME");
  if (homeDirectory != nullptr)
  {
    directoryPath = homeDirectory;
    directoryPath += "/.mitk/";
    AddDirectoryForSearch(directoryPath.c_str(), false);
  }

#endif // defined(_WIN32) && !defined(__CYGWIN__)

  // 3. look in the current working directory
  directoryPath = "";
  AddDirectoryForSearch(directoryPath.c_str());

  directoryPath = Utf8Util::Utf8ToLocal8Bit(kwsys::SystemTools::GetCurrentWorkingDirectory());
  AddDirectoryForSearch(directoryPath.c_str(), false);

  std::string directoryBinPath = directoryPath + "/bin";
  AddDirectoryForSearch(directoryBinPath.c_str(), false);
  // 4. use a source tree location from compile time
  directoryPath = MITK_ROOT;
  if (pathInSourceDir)
  {
    directoryPath += pathInSourceDir;
  }
  directoryPath += '/';
  AddDirectoryForSearch(directoryPath.c_str(), false);

  return SearchDirectoriesForFile(filename);
}

std::string mitk::StandardFileLocations::GetOptionDirectory()
{
  const char *mitkoptions = kwsys::SystemTools::GetEnv("MITKOPTIONS");
  std::string optionsDirectory;

  if (mitkoptions != nullptr)
  {
    // 1. look for MITKOPTIONS environment variable
    optionsDirectory = mitkoptions;
    optionsDirectory += "/";
  }
  else
  {
    // 2. use .mitk-subdirectory in home directory of the user
    std::string homeDirectory;
#if defined(_WIN32) && !defined(__CYGWIN__)
    const char *homeDrive = kwsys::SystemTools::GetEnv("HOMEDRIVE");
    const char *homePath = kwsys::SystemTools::GetEnv("HOMEPATH");
    if ((homeDrive == nullptr) || (homePath == nullptr))
    {
      itkGenericOutputMacro(<< "Environment variables HOMEDRIVE and/or HOMEPATH not set"
                            << ". Using current working directory as home directory: "
                            << Utf8Util::Utf8ToLocal8Bit(kwsys::SystemTools::GetCurrentWorkingDirectory()));
      homeDirectory = Utf8Util::Utf8ToLocal8Bit(kwsys::SystemTools::GetCurrentWorkingDirectory());
    }
    else
    {
      homeDirectory = homeDrive;
      homeDirectory += homePath;
    }
    if (kwsys::SystemTools::FileExists(Utf8Util::Local8BitToUtf8(homeDirectory).c_str()) == false)
    {
      itkGenericOutputMacro(<< "Could not find home directory at " << homeDirectory
                            << ". Using current working directory as home directory: "
                            << Utf8Util::Utf8ToLocal8Bit(kwsys::SystemTools::GetCurrentWorkingDirectory()));
      homeDirectory = Utf8Util::Utf8ToLocal8Bit(kwsys::SystemTools::GetCurrentWorkingDirectory());
    }
#else
    const char *home = kwsys::SystemTools::GetEnv("HOME");
    if (home == nullptr)
    {
      itkGenericOutputMacro(<< "Environment variable HOME not set"
                            << ". Using current working directory as home directory: "
                            << kwsys::SystemTools::GetCurrentWorkingDirectory());
      homeDirectory = kwsys::SystemTools::GetCurrentWorkingDirectory();
    }
    else
      homeDirectory = home;
    if (kwsys::SystemTools::FileExists(homeDirectory.c_str()) == false)
    {
      itkGenericOutputMacro(<< "Could not find home directory at " << homeDirectory
                            << ". Using current working directory as home directory: "
                            << kwsys::SystemTools::GetCurrentWorkingDirectory());
      homeDirectory = kwsys::SystemTools::GetCurrentWorkingDirectory();
    }
#endif // defined(_WIN32) && !defined(__CYGWIN__)

    optionsDirectory = homeDirectory;
    optionsDirectory += "/.mitk";
  }

  optionsDirectory = kwsys::SystemTools::ConvertToOutputPath(Utf8Util::Local8BitToUtf8(optionsDirectory).c_str());
  if (kwsys::SystemTools::CountChar(optionsDirectory.c_str(), '"') > 0)
  {
    char *unquoted = kwsys::SystemTools::RemoveChars(optionsDirectory.c_str(), "\"");
    optionsDirectory = unquoted;
    delete[] unquoted;
  }

  if (kwsys::SystemTools::MakeDirectory(optionsDirectory.c_str()) == false)
  {
    itkGenericExceptionMacro(<< "Could not create .mitk directory at " << Utf8Util::Utf8ToLocal8Bit(optionsDirectory));
  }
  return Utf8Util::Utf8ToLocal8Bit(optionsDirectory);
}
