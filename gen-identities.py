import re
import csv
import requests
from io import StringIO
from datetime import datetime

# Metadata for the four YANG modules produced by this script
MODULES = [
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-17.csv",
        "spaced_name": "encryption",
        "hypenated_name": "encryption",
        "prefix": "sshea",
        "description": """    "This module defines identities for the encryption algorithms
     defined in the 'Encryption Algorithm Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA.""",
    },
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-19.csv",
        "spaced_name": "public key",
        "hypenated_name": "public-key",
        "prefix": "sshpka",
        "description": """    "This module defines identities for the public key algorithms
     defined in the 'Public Key Algorithm Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA."""
    },
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-18.csv",
        "spaced_name": "mac",
        "hypenated_name": "mac",
        "prefix": "sshma",
        "description": """    "This module defines identities for the MAC algorithms
     defined in the 'MAC Algorithm Names' sub-registry of the
     'Secure Shell (SSH) Protocol Parameters' registry maintained
     by IANA."""
    },
    {
        "csv_url": "https://www.iana.org/assignments/ssh-parameters/ssh-parameters-16.csv",
        "spaced_name": "key exchange",
        "hypenated_name": "key-exchange",
        "prefix": "sshkea",
        "description": """    "This module defines identities for the key exchange algorithms
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
     itself for full legal notices.";

  revision DATE {
    description
      "Reflects contents of the SNAME algorithms registry.";
    reference
      "RFC EEEE: YANG Groupings for SSH Clients and SSH Servers";
  }

  // Typedefs

  typedef HNAME-algorithm-ref {
    type identityref {
      base "HNAME-alg-base";
    }
    description
      "A reference to an SSH SNAME algorithm identifier.";
  }


  // Identities

  identity HNAME-alg-base {
    description
      "Base identity for SSH SNAME algorithms.";
  }
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
            def write_identity(alg):
                f.write('\n')
                if row[first_colname].startswith("3des"):
                    f.write(f'  identity {re.sub("3des", "triple-des", alg)} {{\n')
                else:
                    f.write(f'  identity {alg} {{\n')
                f.write(f'    base {module["hypenated_name"]}-alg-base;\n')
                if "HISTORIC" in row["Note"]:
                    f.write(f'    status obsolete;\n')
                elif "OK to Implement" in row:
                    if "SHOULD NOT" in row["OK to Implement"]:
                        f.write(f'    status obsolete;\n')
                    elif "MAY" in row["OK to Implement"]:
                        f.write(f'    status deprecated;\n')
                f.write(f'    description\n')
                f.write(f'      "Identity for the \'{alg}\' algorithm.')
                if "Section" in row["Note"]:
                    f.write("  " + row["Note"])
                f.write(f'";\n')
                f.write( '    reference\n')
                f.write( '      "')
                ref_len = len(refs)
                for i in range(ref_len):
                    ref = refs[i]
                    title = titles[i]
                    f.write(f'{ref}:\n')
                    f.write(f'         {title}')
                    if i != ref_len - 1:
                        f.write('\n       ')
                f.write('";\n')
                f.write('  }\n')

            # Write one or more "identity" statements
            if not row[first_colname].endswith("-*"): # just one identity
                # Avoid duplicate entries caused by the "ecdh-sha2-*" family expansion
                if not row[first_colname].startswith("ecdh-sha2-nistp"):
                    write_identity(row[first_colname])
            else: # a family of identities
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
                    write_identity(row[first_colname][:-1] + curve_id)


def create_module_end(f):

    # Write module's closing brace
    f.write('\n}\n')


def create_module(module):

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
