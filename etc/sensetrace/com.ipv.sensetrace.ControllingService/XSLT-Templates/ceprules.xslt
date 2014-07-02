
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
			<rdf:description rdf:about='urn:classify:notclassified'>
				<dc:clid rdf:datatype="http://www.w3.org/2001/XMLSchema#int">0</dc:clid>
			</rdf:description>
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
			<xsl:variable name="clid">
				<xsl:value-of select="*[local-name() = 'Quantity']/@clid" />
			</xsl:variable>
			<xsl:variable name="replacesensor">
				<xsl:value-of select="*[local-name() = 'Quantity']/@replacesensor" />
			</xsl:variable>
			<xsl:variable name="creationdate">
				<xsl:value-of select="*[local-name() = 'Quantity']/@creationdate" />
			</xsl:variable>
			<xsl:variable name="type">
				<xsl:value-of select="*[local-name() = 'Quantity']/@type" />
			</xsl:variable>
			<xsl:variable name="window">
				<xsl:value-of select="*[local-name() = 'Quantity']/@window" />
			</xsl:variable>
			<xsl:variable name="ceprule">
				<xsl:value-of select="*[local-name() = 'Quantity']/@ceprule" />
			</xsl:variable>
			<xsl:variable name="active">
				<xsl:value-of select="*[local-name() = 'Quantity']/@active" />
			</xsl:variable>
			<xsl:text>&#xa;</xsl:text>
			<rdf:description rdf:about='{$systemid}:{$definition}'>
				<dc:creationdate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">
					<xsl:value-of select="$creationdate" />
				</dc:creationdate>
				<dc:definition>
					<xsl:value-of select="$definition" />
				</dc:definition>
				<dc:window>
					<xsl:value-of select="$window" />
				</dc:window>
				<dc:clid rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$clid" />
				</dc:clid>
				<dc:replacesensor rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
					<xsl:value-of select="$replacesensor" />
				</dc:replacesensor>
				<dc:active>
					<xsl:value-of select="$active" />
				</dc:active>
				<dc:type>
					<xsl:value-of select="$type" />
				</dc:type>
				<dc:ceprule>
					<xsl:value-of select="$ceprule" />
				</dc:ceprule>

			</rdf:description>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>