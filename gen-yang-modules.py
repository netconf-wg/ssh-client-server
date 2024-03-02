import re
import csv
import textwrap
import requests
import requests_cache
from io import StringIO
from datetime import datetime

# Metadata for the four YANG modules produced by this script
MODULES = [
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-17.csv",
        "spaced_name": "encryption",
        "hypenated_name": "encryption",
        "prefix": "sshea",
        "description": """    "This module defines enumerations for the encryption algorithms
     defined in the 'Encryption Algorithm Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA.""",
    },
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-19.csv",
        "spaced_name": "public key",
        "hypenated_name": "public-key",
        "prefix": "sshpka",
        "description": """    "This module defines enumerations for the public key algorithms
     defined in the 'Public Key Algorithm Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA."""
    },
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-18.csv",
        "spaced_name": "mac",
        "hypenated_name": "mac",
        "prefix": "sshma",
        "description": """    "This module defines enumerations for the MAC algorithms
     defined in the 'MAC Algorithm Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA."""
    },
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-16.csv",
        "spaced_name": "key exchange",
        "hypenated_name": "key-exchange",
        "prefix": "sshkea",
        "description": """    "This module defines enumerations for the key exchange algorithms
     defined in the 'Key Exchange Method Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA."""
    },
]




def create_module_begin(module, f):

    # Define template for all four modules
    PREAMBLE_TEMPLATE="""
module iana-ssh-HNAME-algs {
  yang-version 1.1;
  namespace "urn:ietf:params:xml:ns:yang:iana-ssh-HNAME-algs";
  prefix PREFIX;

  organization
    "Internet Assigned Numbers Authority (IANA)";

  contact
    "Postal: ICANN
             12025 Waterfront Drive, Suite 300
             Los Angeles, CA  90094-2536
             United States of America
     Tel:    +1 310 301 5800
     Email:  iana@iana.org";

  description
DESCRIPTION

     Copyright (c) YEAR IETF Trust and the persons identified as
     authors of the code. All rights reserved.

     Redistribution and use in source and binary forms, with
     or without modification, is permitted pursuant to, and
     subject to the license terms contained in, the Revised
     BSD License set forth in Section 4.c of the IETF Trust's
     Legal Provisions Relating to IETF Documents
     (https://trustee.ietf.org/license-info).

     The initial version of this YANG module is part of RFC EEEE
     (https://www.rfc-editor.org/info/rfcEEEE); see the RFC
     itself for full legal notices.

     All versions of this module are published by IANA at
     https://www.iana.org/assignments/yang-parameters.";

  revision DATE {
    description
      "This initial version of the module was created using
       the script defined in RFC EEEE to reflect the contents
       of the SNAME algorithms registry maintained by IANA.";
    reference
      "RFC EEEE: YANG Groupings for SSH Clients and SSH Servers";
  }

  typedef ssh-HNAME-algorithm {
    type enumeration {
"""
    # Replacements
    rep = {
      "DATE": datetime.today().strftime('%Y-%m-%d'),
      "YEAR": datetime.today().strftime('%Y'),
      "SNAME": module["spaced_name"],
      "HNAME": module["hypenated_name"],
      "PREFIX": module["prefix"],
      "DESCRIPTION": module["description"]
    }
    
    # Do the replacement
    rep = dict((re.escape(k), v) for k, v in rep.items()) 
    pattern = re.compile("|".join(rep.keys()))
    text = pattern.sub(lambda m: rep[re.escape(m.group(0))], PREAMBLE_TEMPLATE)

    # Write preamble into the file
    f.write(text)


def create_module_body(module, f):

    # Fetch the current CSV file from IANA
    r = requests.get(module["csv_url"])
    assert(r.status_code == 200)

    # Ascertain the first CSV column's name
    with StringIO(r.text) as csv_file:
        csv_reader = csv.reader(csv_file)
        for row in csv_reader:
            first_colname = row[0]
            break

    # Parse each CSV line
    with StringIO(r.text) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for row in csv_reader:

            # Extract just the ref
            refs = row["Reference"][1:-1]  # remove the '[' and ']' chars
            refs = refs.split("][")

            # There may be more than one ref
            titles = []
            for ref in refs:

                # Ascertain the ref's title
                if ref.startswith("RFC"):

                    # Fetch the current BIBTEX entry
                    bibtex_url="https://datatracker.ietf.org/doc/"+ ref.lower() + "/bibtex/"
                    r = requests.get(bibtex_url)
                    assert r.status_code == 200, "Could not GET " + bibtex_url

                    # Append to 'titles' value from the "title" line
                    for item in r.text.split("\n"):
                        if "title =" in item:
                            titles.append(re.sub('.*{{(.*)}}.*', r'\g<1>', item))
                            break
                    else:
                        raise Exception("RFC title not found")


                    # Insert a space: "RFCXXXX" --> "RFC XXXX"
                    index = refs.index(ref)
                    refs[index] = "RFC " + ref[3:]

                elif ref.startswith("FIPS"):
                    # Special case for FIPS, since no bibtex to fetch
                    if ref == "FIPS 46-3" or ref == "FIPS-46-3":
                        titles.append("Data Encryption Standard (DES)")
                    else:
                        raise Exception("FIPS ref not found")

                else:
                    raise Exception("ref not found")

            # Function used below
            def write_enumeration(alg):
                f.write('\n')
                f.write(f'      enum {alg} {{\n')
                if "HISTORIC" in row["Note"]:
                    f.write(f'        status obsolete;\n')
                elif "OK to Implement" in row:
                    if "MUST NOT" in row["OK to Implement"]:
                        f.write(f'        status obsolete;\n')
                    elif "SHOULD NOT" in row["OK to Implement"]:
                        f.write(f'        status deprecated;\n')
                f.write(f'        description\n')
                description = f'          "Enumeration for the \'{alg}\' algorithm.'
                if "Section" in row["Note"]:
                    description += " " + row["Note"]
                description += '";'
                description = textwrap.fill(description, width=69, subsequent_indent="           ")
                f.write(f'{description}\n')
                f.write('        reference\n')
                f.write('          "')
                if row["Reference"] == "":
                    f.write('    Missing in IANA registry.')
                else:
                    ref_len = len(refs)
                    for i in range(ref_len):
                        ref = refs[i]
                        f.write(f'{ref}:\n')
                        title = "             " + titles[i]
                        if i == ref_len - 1:
                            title += '";'
                        title = textwrap.fill(title, width=67, subsequent_indent="             ")
                        f.write(f'{title}')
                        if i != ref_len - 1:
                            f.write('\n       ')
                f.write('\n')
                f.write('      }\n')


            # Write one or more "enumeration" statements
            if not row[first_colname].endswith("-*"): # just one enumeration
                # Avoid duplicate entries caused by the "ecdh-sha2-*" family expansion
                if not row[first_colname].startswith("ecdh-sha2-nistp"):
                    write_enumeration(row[first_colname])
            else: # a family of enumerations
                curve_ids = [
                    "nistp256",
                    "nistp384",
                    "nistp521",
                    "1.3.132.0.1",
                    "1.2.840.10045.3.1.1",
                    "1.3.132.0.33",
                    "1.3.132.0.26",
                    "1.3.132.0.27",
                    "1.3.132.0.16",
                    "1.3.132.0.36",
                    "1.3.132.0.37",
                    "1.3.132.0.38",
                ]
                for curve_id in curve_ids:
                    write_enumeration(row[first_colname][:-1] + curve_id)


def create_module_end(f):

    # Close out the enumeration, typedef, and module
    f.write("    }\n")
    f.write("    description")
    f.write('      "An enumeration for SSH SNAME algorithms.";')
    f.write("  }\n")
    f.write('\n')
    f.write('}\n')



def create_module(module):

    # Install cache for 8x speedup
    requests_cache.install_cache()

    # ascertain yang module's name
    yang_module_name = "iana-ssh-" + module["hypenated_name"] + "-algs.yang"

    # create yang module file
    with open(yang_module_name, "w") as f:
        create_module_begin(module, f)
        create_module_body(module, f)
        create_module_end(f)


def main():
    for module in MODULES:
        create_module(module)


if __name__ == "__main__":
    main()
