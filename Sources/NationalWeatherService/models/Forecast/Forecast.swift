//
//  Forecast.swift
//  NationalWeatherService
//
//  Created by Alan Chu on 4/2/20.
//

import Foundation

public struct Forecast: Decodable {
    public enum CodingKeys: String, CodingKey {
        case updateTime, generatedAt, validTimes, elevation, periods
    }

    public let updateTime: Date
    public let generatedAt: Date

    // TODO: Handle valid times interval
    public let validTimes: DateInterval
    public let elevation: Measurement<UnitLength>
    public let periods: [Period]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.updateTime = try container.decode(Date.self, forKey: .updateTime)
        self.generatedAt = try container.decode(Date.self, forKey: .generatedAt)

        let validTimesValue = try container.decode(String.self, forKey: .validTimes)
        guard let validTimes = DateInterval.iso8601Interval(from: validTimesValue) else {
            throw DecodingError.dataCorruptedError(forKey: .validTimes, in: container, debugDescription: "Invalid date interval.")
        }
        self.validTimes = validTimes

        let elevationContainer = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .elevation)
        let elevationValue = try elevationContainer.decode(Double.self, forKey: AnyCodingKey(stringValue: "value"))

        self.elevation = Measurement(value: elevationValue, unit: .meters)      // NWS returns elevation in meters regardless of parent unit

        self.periods = try container.decode([Period].self, forKey: .periods)
    }
}
