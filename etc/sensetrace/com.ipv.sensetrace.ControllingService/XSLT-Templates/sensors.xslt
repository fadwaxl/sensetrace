
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:it="http://xmlns.rdfinference.org/ril/issue-tracker" xmlns:rit="http://rdfs.rdfinference.org/ril/issue-tracker#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/"
	version="1.0">

	<xsl:output indent="no" />

	<xsl:param name="it-base"
		select="'http://meta.rdfinference.org/ril/issue-tracker/'" />
	<xsl:param name="it-schema"
		select="'http://rdfs.rdfinference.org/ril/issue-tracker#'" />
	<xsl:param name="it-users"
		select="'http://users.rdfinference.org/ril/issue-tracker#'" />





	<xsl:template match="System">
		<rdf:RDF>
			<xsl:call-template name="handle-item" />
		</rdf:RDF>

	</xsl:template>
	<xsl:template name="handle-item">

		<xsl:variable name="systemid">
			<xsl:value-of select="@id" />
		</xsl:variable>


		<xsl:for-each select="//*[local-name() = 'component']">
			<xsl:variable name="definition">
				<xsl:value-of select="*[local-name() = 'Quantity']/@definition" />
			</xsl:variable>
			<xsl:variable name="mysqlid">
				<xsl:value-of select="*[local-name() = 'Quantity']/@mysqlid" />
			</xsl:variable>
			<xsl:variable name="sensorid">
				<xsl:value-of select="*[local-name() = 'Quantity']/@sensorid" />
			</xsl:variable>
				<xsl:variable name="csvarray">
				<xsl:value-of select="*[local-name() = 'Quantity']/@csvarray" />
			</xsl:variable>
			<xsl:variable name="creationdate">
				<xsl:value-of select="*[local-name() = 'Quantity']/@creationdate" />
			</xsl:variable>
			<xsl:variable name="lowerLimit">
				<xsl:value-of select="*[local-name() = 'Quantity']/@lowerLimit" />
			</xsl:variable>
			<xsl:variable name="upperLimit">
				<xsl:value-of select="*[local-name() = 'Quantity']/@upperLimit" />
			</xsl:variable>
			<xsl:variable name="active">
				<xsl:value-of select="*[local-name() = 'Quantity']/@active" />
			</xsl:variable>
			<xsl:variable name="statictest">
				<xsl:value-of select="*[local-name() = 'Quantity']/@statictest" />
			</xsl:variable>
			<xsl:variable name="differencetopreviousvalue">
				<xsl:value-of
					select="*[local-name() = 'Quantity']/@differencetopreviousvalue" />
			</xsl:variable>
			<xsl:text>&#xa;</xsl:text>
			<rdf:description rdf:about='{$systemid}:{$definition}'>
				<dc:creationdate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
					<xsl:value-of select="$creationdate" />
				</dc:creationdate>
				<dc:definition>
					<xsl:value-of select="$definition" />
				</dc:definition>
				<dc:id rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$sensorid" />
				</dc:id>
				<dc:mysqlid rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$mysqlid" />
				</dc:mysqlid>
				<xsl:choose>
					<xsl:when test="$active='false'">
						<dc:active>
							<xsl:value-of select="$active" />
						</dc:active>
					</xsl:when>
					<xsl:otherwise>
						<dc:active>true</dc:active>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$statictest='false'">
						<dc:statictest>
							<xsl:value-of select="$statictest" />
						</dc:statictest>
					</xsl:when>
					<xsl:otherwise>
						<dc:statictest>true</dc:statictest>
					</xsl:otherwise>
				</xsl:choose>
				<dc:lowerlimit rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$lowerLimit" />
				</dc:lowerlimit>
				<dc:upperlimit rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$upperLimit" />
				</dc:upperlimit>
				<dc:differencetopreviousvalue
					rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$differencetopreviousvalue" />
				</dc:differencetopreviousvalue>
				<dc:csvarray
					rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$csvarray" />
				</dc:csvarray>


			</rdf:description>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
