# VacEngine README

The VacEngine application is an api-based deduction system initially developed by Soignez-Moi.ch under BAG mandate to determine vaccination opportunities based on a person's anonymised information.

## Public review

The VacEngine application has been released to the public (under AGPL Licence, see Software Licence section below) with the hope that it can contribute to the common good. This publication was also made to allow an external contributor to review and make improvement suggestions. Indications about how to share such feedback can be found here:

https://www.ncsc.admin.ch/ncsc/de/home/dokumentation/covid19-vac-check.html  
https://www.ncsc.admin.ch/ncsc/fr/home/dokumentation/covid19-vac-check.html  
https://www.ncsc.admin.ch/ncsc/it/home/dokumentation/covid19-vac-check.html  
https://www.ncsc.admin.ch/ncsc/en/home/dokumentation/covid19-vac-check.html

## Documentation sources

This project contains several documents to help users and developers. Here is a list of these documents and where to find them.

### General documentation
1. **API endpoints** documentation can be found [here](https://vac-engine.github.com/api.html)
2. **Application manual** *available soon*
   
### Technical documentation
1. **Installation** documentation can be found in the [INSTALLATION.md](INSTALLATION.md) file
2. **Development** documentation can be found in the [DEVELOPMENT.md](DEVELOPMENT.md) file
3. **Code** documentation can be found [here](https://vac-engine.github.com/code.html)
4. **Deployment** documentation can be found in the [DEPLOYMENT.md](DEPLOYMENT.md) file
   
## VacEngine functionalities

### Overview

The core functionnality of VacEngine is an API that allows checking the vaccination opportunities based on an anonymised medical profile. The expected input, the structure of the output along with the rules to compute it can be fully customized to answer the different needs of the different regions in switzerland. 

The system allowing to provide such evaluation is called a **processor** and its description is called a **blueprint**.

### API

The application can serve several different processors, each on it's own **portal**. A portal provides a pair of endpoint:
1. The "info" endpoint returns the description of the input to provide to and the output to expect from the processor.
2. The "run" portal that accepts the anonymised profile as input and returns the vaccination opportunities.

### Web application

The user interface of the web application allows to manage the processor descriptions along with the associated portals. Portals and processors are grouped in workspaces that allow to manage several users or groups of users independently, each having access to his/her workspace portals and processors.

## Software Licence (AGPL)

VacEngine is an api-based deduction system initially developed
to determine vaccination opportunities based on a person's
anonymised information.
 
Copyright (C) 2021 Soignez-moi.ch SA Switzerland

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.



