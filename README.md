# Chess-Game

Overview of the project: TETLT of a Kaggle dataset

Tools Used: Microsoft excel, Microsoft Visual Studio, Microsoft SQL Server, PostgreSQL

Functions Used in Various Tools:

Microsoft Excel: Text Query Editor

Microsoft Visual Studio: (Control Flow, Data Flow, Flat File Source(input), Conditional Formatting(transformation), OLE Db Provider(output)

Microsoft SQL Server & PostgreSQL: SQL Queries for Normalisation and transformation

Project: 

The dataset for the project was taken from Kaggle which depicted various Chess Games played. The main aim of this project was to perform TETLT process including the Dataset Normalisation (1NF -> 2NF -> 3NF) in SQL. 

T: The first transformation that was done was in Microsoft Excel, using Text Query Editor the .txt data was loaded and checks were done regarding the 'dates' column and any 'currency' column. File saved as '.csv' post that.

E: The Flat File (.csv) was extracted in Microsoft Visual Studio using the Data flows and control flows, and checks regarding the skewness of data and irregularities of a few of last columns were done during this stage.

T: The input file's quality was assured using the checks made through Conditional Split, which helped in segregating the Good records from bad records.

L: Then the Good records were loaded into the OLE Db Destination (Microsoft SQL Server) as a RAW file, since this file still is in text format (besides 'Date' and 'Currency' (not any here) column)

T: The last transformation was made using SQL Queries in Microsoft SQL Server and PostgreSQL. Here, first the RAW file was converted to proper WRK relational schema so that various checks could be performed. Once that was done, the dataset was normalised in a 1NF, 2NF, 3NF form, where the QA checks were made constantly at each stage. The crucial check and the time consuming step that was encountered here was the 'Duplicate Records' check, and in order to remove the duplicacy, since, it was not just the entire tuples which were duplicately overwritten, a single 'Game id' was occurred multiple times in the dataset and corresponding to those, the other columns' format were slightly changed, leading to the difficulty in removing duplicacy. Using multiple 'WHERE', 'CONDITIONAL OPERATORS', 'GROUP BY', 'HAVING' clauses and constant thinking helped in completing the solution.
