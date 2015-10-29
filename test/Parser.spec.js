import { Parser } from 'jison';
import fs from 'fs';
import _ from 'lodash';

let grammar = fs.readFileSync( './src/parser.jison', 'utf8' );
let expressions = fs.readFileSync( './test/fixtures/expressions.txt', 'utf8' ).split( '\n' );
let positiveTests = fs.readFileSync( './test/fixtures/expressions.txt', 'utf8' ).split( '\n' );
positiveTests = expressions.filter( function ( line ) {
	return !_.startsWith( line, 'x' ) && !_.startsWith(line, '#') && !_.startsWith(line, 'f');
} );

let negativeTests = [];
expressions.forEach( function ( line ) {
	if (_.startsWith(line, 'f')) {
		negativeTests.push(_.trimLeft(line, 'f'));
	}
});
let parser = new Parser( grammar );
let parserSource = parser.generate();

describe( 'Parser', () => {

	it( 'has generated a source', function () {
		expect( parserSource ).to.be.an.object;
	} );

	describe( 'should parse successfully the given expressions:', () => {

		positiveTests.forEach( item => {
			if ( item && !_.isEmpty( item ) ) {
				it( item, function () {
					item = _.trimRight( item, '\r' );
					var r = parser.parse( item );
					expect( r ).to.equal( item );
				} );
			}
		} );
	} );

	describe( 'should successfully fail to parse', () => {
		negativeTests.forEach( item => {
			if ( item && !_.isEmpty( item ) ) {
				it( item, function () {
					item = _.trimRight( item, '\r' );
					expect(parser.parse.bind(null, item)).to.throw(/*whatever*/);
				} );
			}
		} );
	} );

} );

