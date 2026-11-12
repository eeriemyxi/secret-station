#!python.exe
import argparse
import arrow
import os

def get_creation_date(file_path, timezone="India"):
  """
  Gets the creation date of a file in ISO 8601 format with specified timezone.

  Args:
    file_path: The path to the file.
    timezone: The timezone to use for formatting the date (default: India).

  Returns:
    The creation date in ISO 8601 format with specified timezone, or None if the file does not exist.
  """
  if not os.path.exists(file_path):
    return None

  try:
    creation_time = os.path.getctime(file_path)
    arrow_time = arrow.get(creation_time)
    return arrow_time.to("utc").to(timezone).isoformat()
  except OSError as e:
    print(f"Error getting creation date for {file_path}: {e}")
    return None

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description="Get the creation date of a file.")
  parser.add_argument("file", help="Path to the file.")
  parser.add_argument("-t", "--timezone", default="Asia/Kolkata", help="Timezone to use for formatting (default: India)")
  args = parser.parse_args()

  creation_date = get_creation_date(args.file, args.timezone)

  if creation_date:
    print(f"{creation_date}")
  else:
    print("Error getting creation date.")
